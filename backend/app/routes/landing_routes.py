"""
Rutas para la Landing Page de Parrilladas El Establo:
- Catálogo dinámico de la carta y categorías
- Dropdown de platos favoritos (sólo platos gastronómicos reales)
- Registro y seguimiento de visitas (visitante_web, visita_web)
- Registro y tracking de eventos (evento_web)
- Captación y conversión BUYER -> LEAD (persona, buyer, formulario_captacion, lead_conversion, historial_fases)
- Métricas y analítica de Landing Page para el Dashboard React
"""
import logging
import uuid
import re
from datetime import datetime, date
from typing import Any
from flask import Blueprint, jsonify, request
from sqlalchemy import func, distinct, desc
from app.extensions import db
from app.models.catalogo import CategoriaProducto, ProductoCarta, PresentacionProducto
from app.models.web import VisitanteWeb, VisitaWeb, EventoWeb
from app.models.persona import Persona, Buyer
from app.models.conversion import FormularioCaptacion, LeadConversion, HistorialFases

logger = logging.getLogger(__name__)

landing_bp = Blueprint("landing", __name__)


# -----------------------------------------------------------------------------
# 1. CATEGORÍAS DE LA CARTA
# -----------------------------------------------------------------------------
@landing_bp.route("/categorias", methods=["GET"])
def obtener_categorias():
    """
    Retorna el listado de categorías activas ordenadas por su campo orden.
    """
    try:
        categorias = (
            CategoriaProducto.query
            .filter_by(activa=True)
            .order_by(CategoriaProducto.orden.asc())
            .all()
        )
        return jsonify({
            "success": True,
            "data": [c.to_dict() for c in categorias]
        }), 200
    except Exception as e:
        logger.exception("Error al obtener categorías")
        return jsonify({"success": False, "error": str(e)}), 500


# -----------------------------------------------------------------------------
# 2. CARTA COMPLETA JERÁRQUICA (Compatible con estructura carta.model.ts)
# -----------------------------------------------------------------------------
@landing_bp.route("/carta", methods=["GET"])
def obtener_carta():
    """
    Retorna la carta completa organizada por categorías, grupos comerciales y productos,
    con todas sus presentaciones reales y precios vigentes.
    """
    try:
        categorias = (
            CategoriaProducto.query
            .filter_by(activa=True)
            .order_by(CategoriaProducto.orden.asc())
            .all()
        )

        resultado = []
        for cat in categorias:
            # Traer productos activos de esta categoría
            prods = (
                ProductoCarta.query
                .filter_by(id_categoria=cat.id_categoria, activo=True)
                .order_by(ProductoCarta.orden.asc(), ProductoCarta.id_producto.asc())
                .all()
            )

            items_list = []
            for p in prods:
                # Obtener presentaciones activas
                presentaciones = (
                    PresentacionProducto.query
                    .filter_by(id_producto=p.id_producto, activo=True)
                    .order_by(PresentacionProducto.orden.asc(), PresentacionProducto.id_presentacion.asc())
                    .all()
                )

                if presentaciones:
                    for pres in presentaciones:
                        detalle = pres.nombre_presentacion if pres.nombre_presentacion != "Porción estándar" else None
                        items_list.append({
                            "id_producto": p.id_producto,
                            "id_presentacion": pres.id_presentacion,
                            "nombre": p.nombre,
                            "descripcion": pres.descripcion_presentacion or p.descripcion,
                            "detalle": detalle,
                            "grupo": p.grupo_comercial,
                            "precio": float(pres.precio),
                            "destacado": pres.destacado or p.destacado,
                            "imagen": pres.imagen or p.imagen,
                            "unidad_medida": pres.unidad_medida,
                            "peso_volumen": float(pres.peso_volumen_cantidad) if pres.peso_volumen_cantidad is not None else None,
                        })
                else:
                    items_list.append({
                        "id_producto": p.id_producto,
                        "id_presentacion": None,
                        "nombre": p.nombre,
                        "descripcion": p.descripcion,
                        "detalle": f"{int(p.peso_cantidad) if p.peso_cantidad and p.peso_cantidad.is_integer() else p.peso_cantidad} {p.peso_unidad}" if p.peso_cantidad and p.peso_unidad else None,
                        "grupo": p.grupo_comercial,
                        "precio": float(p.precio),
                        "destacado": p.destacado,
                        "imagen": p.imagen,
                        "unidad_medida": p.peso_unidad,
                        "peso_volumen": float(p.peso_cantidad) if p.peso_cantidad is not None else None,
                    })

            resultado.append({
                "id": cat.id_categoria,
                "titulo": cat.titulo,
                "nota": cat.descripcion_nota,
                "orden": cat.orden,
                "items": items_list,
            })

        return jsonify({
            "success": True,
            "data": resultado
        }), 200
    except Exception as e:
        logger.exception("Error al obtener la carta")
        return jsonify({"success": False, "error": str(e)}), 500


# -----------------------------------------------------------------------------
# 3. LISTADO PLANO DE PRODUCTOS Y PRESENTACIONES
# -----------------------------------------------------------------------------
@landing_bp.route("/productos", methods=["GET"])
def obtener_productos():
    """
    Retorna la lista plana de productos con sus presentaciones.
    """
    try:
        prods = (
            ProductoCarta.query
            .filter_by(activo=True)
            .order_by(ProductoCarta.orden.asc(), ProductoCarta.id_producto.asc())
            .all()
        )
        return jsonify({
            "success": True,
            "data": [p.to_dict_full() for p in prods]
        }), 200
    except Exception as e:
        logger.exception("Error al obtener productos")
        return jsonify({"success": False, "error": str(e)}), 500


# -----------------------------------------------------------------------------
# 4. PLATOS FAVORITOS PARA EL FORMULARIO (43 platos gastronómicos reales)
# -----------------------------------------------------------------------------
@landing_bp.route("/platos-favoritos", methods=["GET"])
def obtener_platos_favoritos():
    """
    Retorna exclusivamente los platos aptos para el selector 'Tu plato favorito'
    (cortes de res, cerdo, pollo y combos para compartir). Excluye bebidas, vinos y salsas.
    """
    try:
        prods = (
            ProductoCarta.query
            .filter_by(es_apto_favorito=True, activo=True)
            .order_by(ProductoCarta.orden.asc(), ProductoCarta.id_producto.asc())
            .all()
        )

        favoritos = []
        for p in prods:
            favoritos.append({
                "id_producto": p.id_producto,
                "nombre": p.nombre,
                "categoria": p.categoria,
                "id_categoria": p.id_categoria,
                "grupo_comercial": p.grupo_comercial,
                "precio_desde": float(p.precio),
            })

        return jsonify({
            "success": True,
            "total": len(favoritos),
            "data": favoritos
        }), 200
    except Exception as e:
        logger.exception("Error al obtener platos favoritos")
        return jsonify({"success": False, "error": str(e)}), 500


# -----------------------------------------------------------------------------
# 5. REGISTRO DE VISITAS WEB
# -----------------------------------------------------------------------------
@landing_bp.route("/visitas", methods=["POST"])
def registrar_visita():
    """
    Registra o actualiza un visitante web y crea una nueva sesión de visita.
    Payload esperado:
    {
        "token_visitante": "uuid-v4",
        "token_visita": "uuid-v4",
        "utm_source": "facebook",
        "utm_campaign": "promo_parrillada",
        "id_publicacion": 1,
        "dispositivo_tipo": "ESCRITORIO" | "MOVIL" | "TABLETA" | "DESCONOCIDO"
    }
    """
    try:
        datos = request.get_json() or {}
        raw_token_vis = datos.get("token_visitante")

        # Validar o generar token UUID
        try:
            token_visitante = uuid.UUID(raw_token_vis) if raw_token_vis else uuid.uuid4()
        except (ValueError, AttributeError):
            token_visitante = uuid.uuid4()

        dispositivo = (datos.get("dispositivo_tipo") or "").upper().strip()
        if dispositivo not in ("MOVIL", "ESCRITORIO", "TABLETA", "DESCONOCIDO"):
            dispositivo = "DESCONOCIDO"

        ahora = datetime.utcnow()

        # Buscar o crear VisitanteWeb
        visitante = VisitanteWeb.query.filter_by(token_visitante=token_visitante).first()
        if visitante:
            visitante.cantidad_visitas += 1
            visitante.fecha_ultima_visita = ahora
            if not visitante.dispositivo_tipo or visitante.dispositivo_tipo == "DESCONOCIDO":
                visitante.dispositivo_tipo = dispositivo
        else:
            visitante = VisitanteWeb(
                token_visitante=token_visitante,
                dispositivo_tipo=dispositivo,
                fecha_primera_visita=ahora,
                fecha_ultima_visita=ahora,
                cantidad_visitas=1,
            )
            db.session.add(visitante)
            db.session.flush()

        # Crear VisitaWeb
        utm_source = (datos.get("utm_source") or "").strip() or None
        utm_campaign = (datos.get("utm_campaign") or "").strip() or None
        id_publicacion = datos.get("id_publicacion")
        if id_publicacion is not None:
            try:
                id_publicacion = int(id_publicacion)
            except (ValueError, TypeError):
                id_publicacion = None

        visita = VisitaWeb(
            id_visitante=visitante.id_visitante,
            fecha_inicio=ahora,
            fecha_ultima_actividad=ahora,
            utm_source=utm_source,
            utm_campaign=utm_campaign,
            id_publicacion_origen=id_publicacion,
        )
        db.session.add(visita)
        db.session.commit()

        return jsonify({
            "success": True,
            "id_visita": visita.id_visita,
            "id_visitante": visitante.id_visitante,
            "token_visitante": str(visitante.token_visitante),
        }), 201

    except Exception as e:
        db.session.rollback()
        logger.exception("Error al registrar visita")
        return jsonify({"success": False, "error": str(e)}), 500


# -----------------------------------------------------------------------------
# 6. REGISTRO DE EVENTOS WEB
# -----------------------------------------------------------------------------
@landing_bp.route("/eventos", methods=["POST"])
def registrar_evento():
    """
    Registra un evento interactivo en la landing page:
    Tipos válidos: 'CLIC_CARTA', 'VISTA_CARTA', 'VER_MENU', 'CLIC_FORMULARIO', 'CLIC_WHATSAPP', 'ENVIO_FORMULARIO', 'VER_CARTA'
    """
    try:
        datos = request.get_json() or {}
        id_visita = datos.get("id_visita")
        token_visitante = datos.get("token_visitante")

        # Resolver id_visita si no viene directo
        if not id_visita and token_visitante:
            try:
                tok = uuid.UUID(token_visitante)
                vis = VisitanteWeb.query.filter_by(token_visitante=tok).first()
                if vis:
                    ultima_visita = (
                        VisitaWeb.query
                        .filter_by(id_visitante=vis.id_visitante)
                        .order_by(VisitaWeb.fecha_inicio.desc())
                        .first()
                    )
                    if ultima_visita:
                        id_visita = ultima_visita.id_visita
            except Exception:
                pass

        if not id_visita:
            # Buscar última visita global o crear una si no existe
            ultima_visita = VisitaWeb.query.order_by(VisitaWeb.fecha_inicio.desc()).first()
            if ultima_visita:
                id_visita = ultima_visita.id_visita
            else:
                return jsonify({"success": False, "error": "No existe visita activa para asociar el evento"}), 400

        tipo = (datos.get("tipo") or "").upper().strip()
        tipos_validos = {"VER_MENU", "CLIC_FORMULARIO", "CLIC_WHATSAPP", "ENVIO_FORMULARIO", "CLIC_CARTA", "VISTA_CARTA", "VER_CARTA"}
        if tipo not in tipos_validos:
            tipo = "CLIC_CARTA"

        id_producto = datos.get("id_producto")
        if id_producto:
            try:
                id_producto = int(id_producto)
            except (ValueError, TypeError):
                id_producto = None

        detalle = datos.get("detalle")
        if detalle and len(detalle) > 300:
            detalle = detalle[:300]

        ahora = datetime.utcnow()
        evento = EventoWeb(
            id_visita=id_visita,
            tipo=tipo,
            id_producto=id_producto,
            fecha_evento=ahora,
            detalle=detalle,
        )
        db.session.add(evento)

        # Actualizar fecha de última actividad de la visita
        visita_obj = db.session.get(VisitaWeb, id_visita)
        if visita_obj:
            visita_obj.fecha_ultima_actividad = ahora

        db.session.commit()

        return jsonify({
            "success": True,
            "id_evento": evento.id_evento
        }), 201

    except Exception as e:
        db.session.rollback()
        logger.exception("Error al registrar evento")
        return jsonify({"success": False, "error": str(e)}), 500


# -----------------------------------------------------------------------------
# 7. CAPTACIÓN DE LEAD (BUYER -> LEAD)
# -----------------------------------------------------------------------------
@landing_bp.route("/registros", methods=["POST"])
def registrar_captacion():
    """
    Procesa el formulario de captación convirtiendo a un visitante web anónimo en un LEAD calificado.
    Crea o actualiza:
    - Persona (fase_actual = 'LEAD')
    - Buyer (id_plataforma_origen = 3 [LANDING_PAGE], estado = 'CONVERTIDO_LEAD')
    - FormularioCaptacion (con id_producto_favorito resuelto)
    - LeadConversion (registro formal de la conversión)
    - HistorialFases (transición de fase a LEAD)
    - EventoWeb (tipo = 'ENVIO_FORMULARIO')
    """
    try:
        body = request.get_json() or {}

        # Soportar payload anidado (PayloadCaptacion) o plano
        persona_data = body.get("persona", {})
        form_data = body.get("formulario", {})
        origen_data = body.get("origen", {})

        nombres = (persona_data.get("nombres") or body.get("nombres") or "").strip()
        apellidos = (persona_data.get("apellidos") or body.get("apellidos") or "").strip()
        raw_tel = (persona_data.get("telefono") or body.get("telefono") or "").strip()
        email = (persona_data.get("email") or body.get("email") or "").strip() or None
        fecha_nac_str = persona_data.get("fecha_nacimiento") or body.get("fechaNacimiento")
        acepta_politica = bool(form_data.get("acepta_politica_datos") or body.get("aceptaPoliticaDatos", True))
        acepta_marketing = bool(form_data.get("acepta_marketing") or body.get("aceptaMarketing", False))
        prod_fav_val = form_data.get("producto_favorito") or body.get("idProductoFavorito")

        # Validación básica
        if not nombres or not apellidos:
            return jsonify({"success": False, "error": "Nombres y apellidos son requeridos"}), 400

        # Normalizar celular peruano a 9 dígitos
        digitos = re.sub(r"\D", "", raw_tel)
        if digitos.startswith("51") and len(digitos) > 9:
            telefono = digitos[2:]
        else:
            telefono = digitos

        if not (len(telefono) == 9 and telefono.startswith("9")):
            return jsonify({"success": False, "error": "El celular debe ser peruano de 9 dígitos (inicia con 9)"}), 400

        if not acepta_politica:
            return jsonify({"success": False, "error": "Debe aceptar la política de tratamiento de datos"}), 400

        fecha_nac = None
        if fecha_nac_str:
            try:
                fecha_nac = datetime.strptime(str(fecha_nac_str)[:10], "%Y-%m-%d").date()
            except ValueError:
                fecha_nac = None

        ahora = datetime.utcnow()

        # 1. Buscar o crear PERSONA
        persona = None
        if telefono:
            persona = Persona.query.filter_by(telefono=telefono).first()
        if not persona and email:
            persona = Persona.query.filter_by(email=email).first()

        if persona:
            persona.nombres = nombres
            persona.apellidos = apellidos
            if email and not persona.email:
                persona.email = email
            if fecha_nac and not persona.fecha_nacimiento:
                persona.fecha_nacimiento = fecha_nac
            persona.fase_actual = "LEAD"
            if not persona.consentimiento_datos_fecha:
                persona.consentimiento_datos_fecha = ahora
            if acepta_marketing and not persona.consentimiento_marketing_fecha:
                persona.consentimiento_marketing_fecha = ahora
        else:
            persona = Persona(
                nombres=nombres,
                apellidos=apellidos,
                telefono=telefono,
                email=email,
                fecha_nacimiento=fecha_nac,
                fecha_registro=ahora,
                fase_actual="LEAD",
                consentimiento_datos_fecha=ahora,
                consentimiento_marketing_fecha=ahora if acepta_marketing else None,
            )
            db.session.add(persona)
            db.session.flush()

        # 2. Resolver Visitante y Visita
        raw_tok_vis = origen_data.get("token_visitante") or body.get("token_visitante")
        try:
            tok_vis = uuid.UUID(raw_tok_vis) if raw_tok_vis else uuid.uuid4()
        except (ValueError, AttributeError):
            tok_vis = uuid.uuid4()

        visitante = VisitanteWeb.query.filter_by(token_visitante=tok_vis).first()
        if not visitante:
            visitante = VisitanteWeb(
                token_visitante=tok_vis,
                id_persona=persona.id_persona,
                dispositivo_tipo="DESCONOCIDO",
                fecha_primera_visita=ahora,
                fecha_ultima_visita=ahora,
                cantidad_visitas=1,
            )
            db.session.add(visitante)
            db.session.flush()
        else:
            if not visitante.id_persona:
                visitante.id_persona = persona.id_persona

        # Buscar visita reciente del visitante o crearla
        visita = (
            VisitaWeb.query
            .filter_by(id_visitante=visitante.id_visitante)
            .order_by(VisitaWeb.fecha_inicio.desc())
            .first()
        )
        if not visita:
            utm_source = (origen_data.get("utm_source") or body.get("utm_source") or "").strip() or None
            utm_campaign = (origen_data.get("utm_campaign") or body.get("utm_campaign") or "").strip() or None
            visita = VisitaWeb(
                id_visitante=visitante.id_visitante,
                fecha_inicio=ahora,
                fecha_ultima_actividad=ahora,
                utm_source=utm_source,
                utm_campaign=utm_campaign,
                id_publicacion_origen=origen_data.get("id_publicacion") or form_data.get("id_publicacion_origen"),
            )
            db.session.add(visita)
            db.session.flush()

        # 3. Crear BUYER
        # Plataforma 3 = LANDING_PAGE
        id_publicacion = origen_data.get("id_publicacion") or form_data.get("id_publicacion_origen")
        if id_publicacion:
            try:
                id_publicacion = int(id_publicacion)
            except (ValueError, TypeError):
                id_publicacion = None

        buyer = Buyer(
            id_persona=persona.id_persona,
            id_plataforma_origen=3,
            id_publicacion_origen=id_publicacion,
            referencia_externa=f"WEB_{visitante.token_visitante}",
            fecha_primer_contacto=ahora,
            estado="CONVERTIDO_LEAD",
            fecha_conversion=ahora,
        )
        db.session.add(buyer)
        db.session.flush()

        # Vincular visita al buyer
        visita.id_buyer = buyer.id_buyer

        # 4. Resolver id_producto_favorito
        id_producto_favorito = None
        if prod_fav_val:
            val_str = str(prod_fav_val).strip()
            # Si es id numérico
            if val_str.isdigit():
                p = db.session.get(ProductoCarta, int(val_str))
                if p:
                    id_producto_favorito = p.id_producto
            else:
                # Buscar por coincidencia de nombre
                limpio = re.split(r"\(|\·|\-", val_str)[0].strip()
                p = ProductoCarta.query.filter(
                    ProductoCarta.nombre.ilike(f"%{limpio}%"),
                    ProductoCarta.activo == True
                ).first()
                if p:
                    id_producto_favorito = p.id_producto

        # 5. Crear FORMULARIO_CAPTACION
        formulario = FormularioCaptacion(
            id_persona=persona.id_persona,
            id_buyer=buyer.id_buyer,
            id_plataforma_origen=3,
            id_publicacion_origen=id_publicacion,
            id_visita=visita.id_visita,
            id_sesion_whatsapp=None,
            id_producto_favorito=id_producto_favorito,
            fecha_envio=ahora,
            acepta_politica_datos=True,
            acepta_marketing=acepta_marketing,
        )
        db.session.add(formulario)
        db.session.flush()

        # 6. Registrar LEAD_CONVERSION
        conversion = LeadConversion(
            id_buyer=buyer.id_buyer,
            id_persona=persona.id_persona,
            id_formulario=formulario.id_formulario,
            fecha_conversion=ahora,
        )
        db.session.add(conversion)
        db.session.flush()

        # 7. Registrar HISTORIAL_FASES
        historial_existente = HistorialFases.query.filter_by(
            id_persona=persona.id_persona,
            fase="LEAD"
        ).first()
        if not historial_existente:
            historial = HistorialFases(
                id_persona=persona.id_persona,
                fase="LEAD",
                fecha_cambio=ahora,
                id_buyer=buyer.id_buyer,
                id_formulario=formulario.id_formulario,
            )
            db.session.add(historial)

        # 8. Registrar EVENTO_WEB
        evento = EventoWeb(
            id_visita=visita.id_visita,
            tipo="ENVIO_FORMULARIO",
            id_producto=id_producto_favorito,
            fecha_evento=ahora,
            detalle=f"Lead captado vía web: {persona.nombres} {persona.apellidos} ({telefono})",
        )
        db.session.add(evento)

        db.session.commit()

        return jsonify({
            "success": True,
            "message": "Lead registrado exitosamente",
            "data": {
                "id_persona": persona.id_persona,
                "id_buyer": buyer.id_buyer,
                "id_formulario": formulario.id_formulario,
                "id_conversion": conversion.id_conversion,
                "nombre_completo": f"{persona.nombres} {persona.apellidos}",
                "fase": persona.fase_actual,
            }
        }), 201

    except Exception as e:
        db.session.rollback()
        logger.exception("Error al procesar formulario de captación")
        return jsonify({"success": False, "error": str(e)}), 500


# -----------------------------------------------------------------------------
# 8. MÉTRICAS Y ESTADÍSTICAS PARA EL DASHBOARD REACT
# -----------------------------------------------------------------------------
@landing_bp.route("/estadisticas", methods=["GET"])
def obtener_estadisticas_landing():
    """
    Retorna analítica consolidada de la landing page para el Dashboard React:
    - total_visitas
    - visitantes_unicos
    - clics_carta
    - visitas_carta
    - formularios_exitosos
    - leads_nuevos
    - tasa_conversion (%)
    - visitas_por_dia (serie de tiempo)
    - formularios_recientes (últimas captaciones)
    Permite filtros por query params: fecha_inicio y fecha_fin (YYYY-MM-DD).
    """
    try:
        f_inicio_str = request.args.get("fecha_inicio")
        f_fin_str = request.args.get("fecha_fin")

        f_inicio = None
        f_fin = None
        if f_inicio_str:
            try:
                f_inicio = datetime.strptime(f_inicio_str[:10], "%Y-%m-%d")
            except ValueError:
                pass
        if f_fin_str:
            try:
                # Extender al final del día
                f_fin = datetime.strptime(f_fin_str[:10] + " 23:59:59", "%Y-%m-%d %H:%M:%S")
            except ValueError:
                pass

        # 1. Total visitas y visitantes únicos
        q_visitas = VisitaWeb.query
        if f_inicio:
            q_visitas = q_visitas.filter(VisitaWeb.fecha_inicio >= f_inicio)
        if f_fin:
            q_visitas = q_visitas.filter(VisitaWeb.fecha_inicio <= f_fin)

        total_visitas = q_visitas.count()
        visitantes_unicos = q_visitas.with_entities(func.count(distinct(VisitaWeb.id_visitante))).scalar() or 0

        # 2. Clics en la carta (CLIC_CARTA, VER_MENU)
        q_clics = EventoWeb.query.filter(EventoWeb.tipo.in_(["CLIC_CARTA", "VER_MENU"]))
        if f_inicio:
            q_clics = q_clics.filter(EventoWeb.fecha_evento >= f_inicio)
        if f_fin:
            q_clics = q_clics.filter(EventoWeb.fecha_evento <= f_fin)
        clics_carta = q_clics.count()

        # 3. Visitas a la página de la carta (VISTA_CARTA, VER_CARTA)
        q_vista_carta = EventoWeb.query.filter(EventoWeb.tipo.in_(["VISTA_CARTA", "VER_CARTA"]))
        if f_inicio:
            q_vista_carta = q_vista_carta.filter(EventoWeb.fecha_evento >= f_inicio)
        if f_fin:
            q_vista_carta = q_vista_carta.filter(EventoWeb.fecha_evento <= f_fin)
        visitas_carta = q_vista_carta.count()

        # 4. Formularios exitosos (plataforma 3 = LANDING_PAGE)
        q_forms = FormularioCaptacion.query.filter_by(id_plataforma_origen=3)
        if f_inicio:
            q_forms = q_forms.filter(FormularioCaptacion.fecha_envio >= f_inicio)
        if f_fin:
            q_forms = q_forms.filter(FormularioCaptacion.fecha_envio <= f_fin)
        formularios_exitosos = q_forms.count()

        # 5. LEADS nuevos (LeadConversion vinculados a formularios de landing)
        q_leads = (
            LeadConversion.query
            .join(FormularioCaptacion, LeadConversion.id_formulario == FormularioCaptacion.id_formulario)
            .filter(FormularioCaptacion.id_plataforma_origen == 3)
        )
        if f_inicio:
            q_leads = q_leads.filter(LeadConversion.fecha_conversion >= f_inicio)
        if f_fin:
            q_leads = q_leads.filter(LeadConversion.fecha_conversion <= f_fin)
        leads_nuevos = q_leads.count()

        # 6. Tasa de conversión
        tasa_conversion = round((leads_nuevos / visitantes_unicos * 100), 2) if visitantes_unicos > 0 else 0.0

        # 7. Serie de tiempo diaria
        # Agrupación por fecha de VisitaWeb
        q_dias = (
            db.session.query(
                func.cast(VisitaWeb.fecha_inicio, db.Date).label("fecha"),
                func.count(VisitaWeb.id_visita).label("visitas"),
                func.count(distinct(VisitaWeb.id_visitante)).label("visitantes"),
            )
        )
        if f_inicio:
            q_dias = q_dias.filter(VisitaWeb.fecha_inicio >= f_inicio)
        if f_fin:
            q_dias = q_dias.filter(VisitaWeb.fecha_inicio <= f_fin)

        filas_dias = q_dias.group_by(func.cast(VisitaWeb.fecha_inicio, db.Date)).order_by(func.cast(VisitaWeb.fecha_inicio, db.Date).asc()).all()

        visitas_por_dia = [
            {
                "fecha": fila.fecha.strftime("%Y-%m-%d") if fila.fecha else "",
                "visitas": fila.visitas,
                "visitantes": fila.visitantes,
            }
            for fila in filas_dias
        ]

        # 8. Formularios recientes (últimos 15)
        recientes = (
            FormularioCaptacion.query
            .filter_by(id_plataforma_origen=3)
            .order_by(FormularioCaptacion.fecha_envio.desc())
            .limit(15)
            .all()
        )

        formularios_recientes = []
        for f in recientes:
            nom_plato = f.producto_favorito.nombre if f.producto_favorito else "No especificado"
            vis = f.visita if hasattr(f, "visita") and f.visita else None
            formularios_recientes.append({
                "id_formulario": f.id_formulario,
                "persona_nombre": f"{f.persona.nombres} {f.persona.apellidos}" if f.persona else "Desconocido",
                "telefono": f.persona.telefono if f.persona else "",
                "email": f.persona.email if f.persona else "",
                "plato_favorito": nom_plato,
                "utm_source": vis.utm_source if vis and vis.utm_source else "Directo",
                "utm_campaign": vis.utm_campaign if vis and vis.utm_campaign else None,
                "fecha_envio": f.fecha_envio.strftime("%Y-%m-%d %H:%M:%S") if f.fecha_envio else "",
                "acepta_marketing": f.acepta_marketing,
            })

        return jsonify({
            "success": True,
            "resumen": {
                "total_visitas": total_visitas,
                "visitantes_unicos": visitantes_unicos,
                "clics_carta": clics_carta,
                "visitas_carta": visitas_carta,
                "formularios_exitosos": formularios_exitosos,
                "leads_nuevos": leads_nuevos,
                "tasa_conversion": tasa_conversion,
            },
            "visitas_por_dia": visitas_por_dia,
            "formularios_recientes": formularios_recientes,
        }), 200

    except Exception as e:
        logger.exception("Error al obtener estadísticas de landing")
        return jsonify({"success": False, "error": str(e)}), 500
