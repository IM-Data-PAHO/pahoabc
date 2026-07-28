# PAHOabc <img src="man/figures/logo.png" align="right" height="138" />

> 🌐 [**Read this in English**](https://im-data-paho.github.io/pahoabc/index.html)

PAHOabc es un paquete de R orientado a análisis de inmunización más allá de la cobertura (*(A)nalysis (B)eyond (C)overage*).

PAHOabc busca apoyar la misión de la Unidad de Inmunización Integral (CIM) de la Organización Panamericana de la Salud (OPS) con herramientas de análisis de datos para los programas de inmunización en las Américas. En concreto, facilita el cálculo de indicadores más allá de la cobertura básica, apoya la toma de decisiones basada en evidencia mediante la exploración y visualización de datos, y contribuye a fortalecer las capacidades de los programas de inmunización para aprovechar mejor sus datos.

Para conocer más sobre el trabajo de la OPS en inmunización, visite el [sitio de Inmunización de la OPS](https://www.paho.org/es/temas/inmunizacion).

Para la documentación y las viñetas de este paquete de R, consulte: [https://im-data-paho.github.io/pahoabc](https://im-data-paho.github.io/pahoabc).

## Instalación

```r
# Instalar desde GitHub
devtools::install_github("IM-Data-PAHO/pahoabc")
```

## Uso

Actualmente, PAHOabc contiene seis módulos principales. Siga los enlaces a continuación para explorar viñetas detalladas con ejemplos prácticos y orientación sobre cómo usar cada módulo:

1. [**Tasa de abandono nominal**](https://im-data-paho.github.io/pahoabc/articles/es/nominal_dropout_es.html)  
   Calcula las tasas de abandono entre cualquier par de dosis de vacunas utilizando datos nominales. Este módulo permite dar seguimiento a la continuidad de las personas dentro de un esquema de vacunación.

2. [**Análisis de residencia vs. lugar de vacunación**](https://im-data-paho.github.io/pahoabc/articles/es/residence_occurrence_es.html)  
   Funciones para comparar la cobertura de vacunación y la distribución de dosis según el lugar donde viven las personas y el lugar donde fueron vacunadas. Este módulo ayuda a identificar flujos poblacionales y posibles brechas en la cobertura de los servicios entre áreas geográficas.

3. [**Cobertura de esquema completo**](https://im-data-paho.github.io/pahoabc/articles/es/complete_schedule_es.html)  
   Evalúa si las personas han recibido todas las dosis requeridas en un esquema nacional de vacunación, para una cohorte específica hasta una edad determinada. Este módulo se diferencia del cálculo de cobertura estándar porque evalúa el cumplimiento del esquema persona por persona.

4. [**Cobertura por cohorte de nacimiento**](https://im-data-paho.github.io/pahoabc/articles/es/birth_cohort_coverage_es.html)  
   Permite dar seguimiento y visualizar el estado de vacunación de una cohorte específica de recién nacidos. Ayuda a evaluar la protección de la población frente a las enfermedades prevenibles por vacunación.

5. [**Comparación de consistencia de fechas**](https://im-data-paho.github.io/pahoabc/articles/es/date_consistency_comparison_es.html)  
   Identifica y cuantifica inconsistencias lógicas entre cualquier par de variables de fecha en el RNVe (p. ej., fecha de vacunación anterior a la fecha de nacimiento). Ayuda a detectar errores de captura y problemas de vinculación de registros antes de los análisis posteriores.

6. [**Comparación de consistencia de elegibilidad**](https://im-data-paho.github.io/pahoabc/articles/es/eligibility_consistency_comparison_es.html)  
   Identifica y cuantifica si los eventos de vacunación ocurrieron dentro de la ventana de edad definida por el esquema nacional de vacunación. Ayuda a detectar dosis inelegibles administradas demasiado temprano o demasiado tarde, señalando posibles problemas de oportunidad en la prestación del servicio.

Cada módulo funciona con los conjuntos de datos de ejemplo incluidos en el paquete. Estos datos facilitan probar las funciones y sirven de referencia al preparar sus propios datos. Conozca más sobre estos conjuntos de datos de ejemplo [en esta viñeta](https://im-data-paho.github.io/pahoabc/articles/es/example_datasets_es.html).

> **Nota**
> 
> Puede explorar todas las viñetas disponibles haciendo clic en el botón **Guides** (Guías) de la barra de navegación.

## Contribuir

Agradecemos sugerencias, reportes de errores y solicitudes de nuevas funciones a través de la página de [incidencias de GitHub](https://github.com/IM-Data-PAHO/pahoabc/issues). Si desea contribuir con código o correcciones, puede abrir una [solicitud de incorporación de cambios](https://github.com/IM-Data-PAHO/pahoabc/pulls).
