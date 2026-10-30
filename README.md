# WallDisplay_CentroComercialAljub

**WallDisplay** is a giant digital display installation for a shopping centre, built as a set of
**Adobe AIR / Flash (ActionScript 3)** applications:

- **pantalla** (the display itself): full-screen viewer that shows images and videos (`.flv/.mov`)
  following a content plan (XML). It includes an **Arduino UNO sensor** (installed on the escalators
  at the entrance): an analog level read on pin A0 is polled via TCP through **serproxy** (port
  5331, serial COM4 @57600), smoothed and thresholded in `Pantalla.as` to trigger/energise the
  on-screen content. On-screen calibration aids (`Barra`, `Indicador`) are included.
- **gestor** (desktop manager app): AIR application to plan **which content to display and when**
  — panels to pick media files, dates and time slots; the plan is stored as XML
  (`DOC_XML`) next to the display configuration. Compiled and shipped as `gestor.app`.
- The viewer connects both apps: the `gestor` writes the display plan, and `pantalla` renders it.

Included third-party components (kept in the repository for reference, as they are abandoware /
hard to find today): the **AS3↔Arduino Flash library by Erik Sjödin** (`net/`), the
**serproxy** serial-to-TCP proxy, and the serial configuration (`serproxy.cfg`).

> **This project is shared ONLY for educational purposes. Its use, direct or derived, for professional or economic purposes is not permitted.**

For security reasons, some parts of the project may have been edited or removed (develop
documentation and duplicated working folders are not included; the compiled applications and the
third-party installers are provided as GitHub Release assets).

## Repository structure

| Folder | Contents |
|---|---|
| (root) | Source of the display viewer: `pantalla.fla` + `Pantalla.as` + `pantalla-app.xml`, compiled `pantalla.swf`, `net/` (AS3↔Arduino library), `serproxy.exe/.cfg`, GreenSock/textLayout libs. |
| `gestor/` | Source of the schedule manager: `gestor.fla` + AS3 classes (`Gestor`, panels for files/dates/horarios) + compiled `gestor.swf`. |
| `media/` | Sample display contents: images and `flv/mov` videos used by the viewer. |
| `release/` | (Not in the repo) final deliverables: the whole compiled `pantalla.app` (with the Adobe AIR runtime, serproxy and media), `pantalla con nuevo gestor.zip`, and `soft/` with **third-party installers** (Arduino IDE 1.0.5-r2, RealVNC 5.1 server/viewer). Published as **GitHub Release assets**. |

## Requirements / How to run

- **Editing / building**: Adobe Flash Professional / Animate CC (sources are `.fla` + `.as`,
  ActionScript 3, Adobe AIR `application/15.0` descriptors) with GreenSock TweenNano
  (`greensock.swc`, included) and textLayout (`.swz`, included).
- **Display**: run the compile of `pantalla.fla` as an AIR application on the display PC
  (a ready-made `pantalla.app` build is available as a Release asset). Contents are read from a
  `media/` folder next to the app and scheduled via the XML plan.
- **Manager**: build/run `gestor.fla` (AIR) to edit the display plan; export produces the XML the
  viewer consumes.
- **Hardware**: an **Arduino UNO** on the escalators with a sensor on analog pin A0, connected by
  USB to the display PC where **serproxy** must be running (`serproxy.cfg` expects COM4 @57600
  bridged to TCP port 5331; adapt serial port/net port as needed). The viewer polls
  `localhost:5331` every frame (50 fps refresh) and smooths the analog level to trigger content.
  *No Arduino sketch is included in this folder — the board can be read with analogRead on A0.*
- calibrate the threshold with the on-screen bar/indicator included in `pantalla`.

## DISCLAIMER

This software is provided "as is", without any warranty of any kind. No liability is accepted for
errors or damages resulting from its use.

> **AI training**: the use of the content of this repository (code, assets, documentation) to
> train or fine-tune machine learning models or AI systems is expressly **not permitted**.
> All of the repository is licensed under CC-BY-NC-4.0 (see the `LICENSE` file).

---

# WallDisplay_CentroComercialAljub

**WallDisplay** es una instalación de pantalla digital gigante para un centro comercial,
construida como conjunto de aplicaciones **Adobe AIR / Flash (ActionScript 3)**:

- **pantalla** (el visor): visor a pantalla completa que muestra imágenes y vídeos (`.flv/.mov`)
  siguiendo un plan de contenidos (XML). Incluye un **sensor Arduino UNO** (instalado en las
  escaleras mecánicas de la entrada): se lee un nivel analógico en el pin A0 vía TCP a través de
  **serproxy** (puerto 5331, COM4 serie @57600), se suaviza y se compara con un umbral en
  `Pantalla.as` para activar/animar el contenido de la pantalla. Incluye ayudas de calibración
  en pantalla (`Barra`, `Indicador`).
- **gestor** (app de escritorio): aplicación AIR para planificar **qué contenido mostrar y
  cuándo** — paneles para elegir archivos de medios, fechas y horarios; el plan se guarda como
  XML (`DOC_XML`) junto a la configuración del visor. Se compiló y se entrega como `gestor.app`.
- Ambas apps se conectan: el `gestor` escribe el plan y `pantalla` lo reproduce.

Componentes de terceros incluidos (conservados en el repositorio por ser abandonware / difíciles
de encontrar en otros sitios): la **librería Flash AS3↔Arduino de Erik Sjödin** (`net/`), el
**proxy serie serproxy** y su configuración (`serproxy.cfg`).

> **Este proyecto se comparte SOLO con valor educativo. No está permitido su uso (directo o derivado) para fines profesionales o económicos.**

Por motivos de seguridad y de licencias, es posible que algunas partes del proyecto estén editadas
o eliminadas (se ha retirado la documentación de desarrollo y las carpetas de trabajo duplicadas;
las aplicaciones compiladas y los instaladores de terceros se publican como assets del Release de
GitHub).

## Estructura del repositorio

| Carpeta | Contenido |
|---|---|
| (raíz) | Fuente del visor: `pantalla.fla` + `Pantalla.as` + `pantalla-app.xml`, `pantalla.swf` compilado, `net/` (librería AS3↔Arduino), `serproxy.exe/.cfg`, librerías GreenSock/textLayout. |
| `gestor/` | Fuente del gestor de horarios: `gestor.fla` + clases AS3 (`Gestor`, paneles de archivos/fechas/horarios) + `gestor.swf` compilado. |
| `media/` | Contenidos de ejemplo de la pantalla: imágenes y vídeos `flv/mov` que usa el visor. |
| `release/` | (No está en el repo) entregables finales: la app completa compilada `pantalla.app` (con el runtime de Adobe AIR, serproxy y los medios), `pantalla con nuevo gestor.zip`, y `soft/` con **instaladores de terceros** (Arduino IDE 1.0.5-r2, RealVNC 5.1 servidor/visor). Se publican como **assets del Release de GitHub**. |

## Requisitos / Cómo ejecutar

- **Edición / compilación**: Adobe Flash Professional / Animate CC (fuentes `.fla` + `.as`,
  ActionScript 3, descriptores Adobe AIR `application/15.0`) con GreenSock TweenNano
  (`greensock.swc`, incluido) y textLayout (`.swz`, incluido).
- **Pantalla**: compilar y ejecutar `pantalla.fla` como aplicación AIR en el PC de la pantalla
  (hay un build listo `pantalla.app` como asset del Release). Los contenidos se leen de una
  carpeta `media/` junto a la app y se planifican con el XML del gestor.
- **Gestor**: compilar/ejecutar `gestor.fla` (AIR) para editar el plan de la pantalla; genera el
  XML que consume el visor.
- **Hardware**: un **Arduino UNO** en las escaleras mecánicas con un sensor en el pin analógico
  A0, conectado por USB al PC de la pantalla donde debe estar corriendo **serproxy**
  (`serproxy.cfg` espera COM4 @57600 puenteado al puerto TCP 5331; adaptar puerto serie/puerto
  net según instalación). El visor consulta `localhost:5331` en cada fotograma (refresco 50 fps)
  y suaviza el nivel analógico para activar el contenido.
- Calibrar el umbral con la barra/indicador incluidos en pantalla.

## AVISO

Este software se facilita "tal cual", sin ningún tipo de garantía. No se acepta ninguna
responsabilidad por errores o daños que puedan producirse por su uso.

> **Entrenamiento de IA**: no se permite expresamente el uso del contenido de este repositorio
> (código, recursos, documentación) para entrenar o ajustar (*fine-tune*) modelos de aprendizaje
> automático o sistemas de IA. Todo el repositorio se publica con licencia CC-BY-NC-4.0 (ver el
> archivo `LICENSE`).
