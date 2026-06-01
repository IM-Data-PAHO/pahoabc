# PAHOabc <img src="man/figures/logo.png" align="right" height="138" />

> 🌐 [**Read this in English**](https://im-data-paho.github.io/pahoabc/index.html)

PAHOabc es un paquete de R orientado a (A)nálisis de inmunización (B)eyond (C)overage, es decir, más allá de la cobertura.

PAHOabc busca apoyar la misión de la Unidad de Inmunización Integral de la Familia (CIM) de la Organización Panamericana de la Salud (OPS) proporcionando herramientas avanzadas de análisis de datos para los programas de inmunización en las Américas. En concreto, facilita el cálculo de indicadores innovadores más allá de la cobertura básica, apoya la toma de decisiones basada en evidencia mediante la exploración y visualización profunda de los datos, y contribuye a fortalecer las capacidades de datos dentro de los programas de inmunización al empoderar al talento humano para aprovechar eficazmente sus datos.

Para la documentación y las viñetas, consulte: [https://im-data-paho.github.io/pahoabc](https://im-data-paho.github.io/pahoabc).

## Instalación

```r
# Instalar desde GitHub
devtools::install_github("IM-Data-PAHO/pahoabc")
```

## Uso

Actualmente, PAHOabc contiene cuatro módulos principales. Siga los enlaces a continuación para explorar viñetas detalladas con ejemplos prácticos y orientación sobre cómo usar cada módulo:

1. [**Tasa de deserción nominal**](https://im-data-paho.github.io/pahoabc/articles/es/nominal_dropout_es.html)  
   Calcula las tasas de deserción entre cualquier par de dosis de vacunas utilizando datos nominales. Este módulo permite un seguimiento preciso a lo largo de un esquema de vacunación.

2. [**Análisis de residencia vs. ocurrencia**](https://im-data-paho.github.io/pahoabc/articles/es/residence_occurrence_es.html)  
   Funciones para comparar la cobertura de vacunación y la distribución de dosis según el lugar donde residen las personas frente al lugar donde fueron vacunadas. Este módulo ayuda a identificar el movimiento de la población y las brechas en la cobertura de los servicios entre áreas geográficas.

3. [**Cobertura de esquema completo**](https://im-data-paho.github.io/pahoabc/articles/es/complete_schedule_es.html)  
   Evalúa si las personas han recibido todas las dosis requeridas en un esquema nacional de vacunación (para una cohorte específica hasta una edad determinada). Este módulo se diferencia del cálculo de cobertura estándar, ya que evalúa el cumplimiento del esquema nacional de vacunación por cada individuo.

4. [**Cobertura por cohorte de nacimiento**](https://im-data-paho.github.io/pahoabc/articles/es/birth_cohort_coverage_es.html)  
   Permite a los usuarios monitorear y visualizar el estado de vacunación de una cohorte específica de recién nacidos. Ayuda a evaluar la protección a nivel poblacional frente a las enfermedades prevenibles por vacunación.

Cada módulo funciona sin inconvenientes con los conjuntos de datos de ejemplo incluidos en el paquete. Estos ejemplos facilitan probar la funcionalidad y sirven de referencia al preparar sus propios datos. Conozca más sobre estos conjuntos de datos de ejemplo [en esta viñeta](https://im-data-paho.github.io/pahoabc/articles/es/example_datasets_es.html).

> **Nota**
> 
> Puede explorar todas las viñetas disponibles haciendo clic en el botón **Guides** de la barra de navegación.

## Contribuir

Agradecemos sugerencias, reportes de errores y solicitudes de nuevas funciones a través de la página de [GitHub Issues](https://github.com/IM-Data-PAHO/pahoabc/issues). Si desea contribuir con código o correcciones, no dude en abrir un [pull request](https://github.com/IM-Data-PAHO/pahoabc/pulls).
