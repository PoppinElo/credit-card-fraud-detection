# EDA Findings — Predicting Credit Card Fraud

## 1. Objetivo y alcance

Este documento registra los principales hallazgos del análisis exploratorio de datos (EDA) realizado sobre `raw.train` para la competencia **Playground Series S6E11 — Predicting Credit Card Fraud**.

El objetivo del EDA es comprender la distribución de la variable objetivo, explorar cómo se comportan las variables predictoras frente a la etiqueta de fraude e identificar posibles señales e interacciones que merezcan evaluarse durante el feature engineering y el modelado.

**Alcance:** los análisis de fraude de este documento se realizan sobre el conjunto `train`, porque es el único que contiene `is_fraud`. El conjunto `test` no tiene etiqueta y, por tanto, no se utiliza para calcular tasas de fraude.

Las tasas y diferencias descritas son asociaciones observadas en los datos. No demuestran causalidad ni, por sí solas, la capacidad predictiva de una variable.

---

## 2. Resumen del conjunto de datos

Después de ejecutar el pipeline ETL y cargar los datos en PostgreSQL:

| Tabla | Registros |
|---|---:|
| `raw.train` | 699,960 |
| `raw.test` | 299,984 |
| `raw.sample_submission` | 299,984 |

Las validaciones previas a la carga y las comprobaciones posteriores confirmaron:

- No se encontraron valores nulos en los archivos originales.
- No se encontraron registros duplicados en los archivos originales.
- Los identificadores de `train` y `test` no se solapan.
- Los identificadores de `sample_submission` están alineados con los de `test`.
- La variable objetivo contiene valores binarios válidos.

### 2.1 Distribución de la variable objetivo

| `is_fraud` | Transacciones | Porcentaje |
|---:|---:|---:|
| 0 — No fraude | 688,271 | 98.33% |
| 1 — Fraude | 11,689 | 1.67% |
| **Total** | **699,960** | **100.00%** |

La clase positiva representa aproximadamente el 1.67% de las observaciones. Existe, por tanto, un **fuerte desbalance de clases**.

Un clasificador que siempre predijera la clase mayoritaria obtendría una accuracy cercana al 98.33%, pero no detectaría ningún fraude. Por eso, la accuracy no sería una métrica suficiente para evaluar el problema. La competencia utiliza **ROC-AUC**, que evalúa la capacidad del modelo para ordenar los casos positivos por encima de los negativos a través de distintos umbrales.

---

## 3. Variables numéricas

Las comparaciones de esta sección son descriptivas. Las diferencias entre medias, medianas o tasas por grupos no deben interpretarse como evidencia causal.

### 3.1 `amount_usd`

| Estadística | No fraude | Fraude |
|---|---:|---:|
| Media | 79.37 | 110.50 |
| Q1 | 15.77 | 16.77 |
| Mediana | 27.21 | 31.18 |
| Q3 | 42.95 | 49.89 |
| Mínimo | 1.00 | 1.00 |
| Máximo | 6,872.69 | 6,078.29 |

El monto medio de las transacciones fraudulentas es aproximadamente un 39.3% mayor que el de las legítimas. La mediana y los cuartiles también son algo superiores, aunque las distribuciones presentan solapamiento.

La tasa de fraude por rangos de monto fue:

| Rango de monto (USD) | Transacciones | Fraudes | Tasa de fraude |
|---|---:|---:|---:|
| < 25 | 318,611 | 4,810 | 1.51% |
| 25–49.99 | 259,357 | 3,977 | 1.53% |
| 50–99.99 | 53,857 | 933 | 1.73% |
| 100–249.99 | 15,857 | 614 | 3.87% |
| 250–499.99 | 11,500 | 346 | 3.01% |
| >= 500 | 40,778 | 1,009 | 2.47% |

El rango de USD 100–249.99 presenta la tasa más alta (3.87%), aproximadamente 2.3 veces la tasa global. No se observa un crecimiento lineal de la tasa conforme aumenta el monto. El rango inferior a USD 25 contiene la mayor cantidad absoluta de fraudes, pero su tasa es de 1.51%.

**Lectura:** `amount_usd` muestra diferencias descriptivas entre clases y podría aportar señal, pero conviene modelar su distribución sin asumir una relación lineal o monotónica.

### 3.2 `account_balance_usd`

| Estadística | No fraude | Fraude |
|---|---:|---:|
| Media | 2,064.52 | 2,093.09 |
| Q1 | 834.02 | 841.36 |
| Mediana | 1,382.74 | 1,396.00 |
| Q3 | 2,516.25 | 2,611.10 |
| Mínimo | 58.25 | 58.89 |
| Máximo | 99,701.39 | 88,566.00 |

Las estadísticas marginales son similares. Al dividir la variable en quintiles de igual cantidad de observaciones, se obtuvieron estas tasas:

| Quintil | Rango aproximado | Transacciones | Fraudes | Tasa |
|---:|---:|---:|---:|---:|
| 1 | 58.25–751.78 | 139,992 | 2,312 | 1.65% |
| 2 | 751.78–1,139.47 | 139,992 | 2,262 | 1.62% |
| 3 | 1,139.52–1,676.18 | 139,992 | 2,362 | 1.69% |
| 4 | 1,676.18–2,895.20 | 139,992 | 2,211 | 1.58% |
| 5 | 2,895.20–99,701.39 | 139,992 | 2,542 | 1.82% |

No aparece una tendencia marcada. El quinto quintil tiene una tasa ligeramente superior, pero las diferencias son pequeñas.

**Lectura:** la asociación marginal con el fraude parece débil. Esto no implica que la variable deba descartarse: podría aportar información en combinación con otras variables.

### 3.3 `distance_from_home_km`

| Estadística | No fraude | Fraude |
|---|---:|---:|
| Media | 13.58 | 13.75 |
| Q1 | 4.43 | 4.44 |
| Mediana | 10.22 | 10.31 |
| Q3 | 19.74 | 20.17 |
| Mínimo | 0.00 | 0.01 |
| Máximo | 57.93 | 52.77 |

Las distribuciones presentan estadísticas muy parecidas. Las tasas por quintiles también son estables:

| Quintil | Rango aproximado (km) | Transacciones | Fraudes | Tasa |
|---:|---:|---:|---:|---:|
| 1 | 0–3.33 | 139,992 | 2,267 | 1.62% |
| 2 | 3.33–7.59 | 139,992 | 2,345 | 1.68% |
| 3 | 7.59–13.51 | 139,992 | 2,350 | 1.68% |
| 4 | 13.51–22.73 | 139,992 | 2,349 | 1.68% |
| 5 | 22.73–57.93 | 139,992 | 2,378 | 1.70% |

**Lectura:** no se observa una relación marginal importante entre esta variable y la etiqueta de fraude en los grupos examinados.

### 3.4 `hours_since_last_txn`

| Estadística | No fraude | Fraude |
|---|---:|---:|
| Media | 6.65 | 5.64 |
| Q1 | 2.12 | 1.40 |
| Mediana | 4.73 | 3.61 |
| Q3 | 9.22 | 7.82 |
| Mínimo | 0.01 | 0.01 |
| Máximo | 51.98 | 48.10 |

Las transacciones fraudulentas presentan intervalos más cortos respecto de la transacción anterior. La mediana es de 3.61 horas en fraude frente a 4.73 horas en no fraude.

Por quintiles:

| Quintil | Rango aproximado (horas) | Transacciones | Fraudes | Tasa |
|---:|---:|---:|---:|---:|
| 1 | 0.01–1.71 | 139,992 | 3,506 | 2.50% |
| 2 | 1.71–3.62 | 139,992 | 2,355 | 1.68% |
| 3 | 3.62–6.14 | 139,992 | 2,002 | 1.43% |
| 4 | 6.14–10.47 | 139,992 | 1,905 | 1.36% |
| 5 | 10.47–51.98 | 139,992 | 1,921 | 1.37% |

El primer quintil presenta una tasa de 2.50%, casi 1.5 veces la tasa global. La tasa desciende en los siguientes quintiles y se estabiliza en los dos últimos.

**Lectura:** los intervalos más cortos muestran una asociación descriptiva destacada con el fraude. La relación no es estrictamente monotónica en todos los grupos.

### 3.5 `txn_count_last_24h`

| Estadística | No fraude | Fraude |
|---|---:|---:|
| Media | 2.97 | 3.65 |
| Q1 | 2 | 3 |
| Mediana | 3 | 4 |
| Q3 | 4 | 5 |
| Mínimo | 0 | 0 |
| Máximo | 11 | 11 |

Las transacciones fraudulentas presentan una mayor cantidad de transacciones en las últimas 24 horas.

| Transacciones en 24 h | Total | Fraudes | Tasa de fraude |
|---:|---:|---:|---:|
| 0 | 18,462 | 43 | 0.23% |
| 1 | 92,705 | 640 | 0.69% |
| 2 | 170,757 | 2,184 | 1.28% |
| 3 | 178,367 | 2,969 | 1.66% |
| 4 | 131,869 | 2,609 | 1.98% |
| 5 | 69,701 | 1,805 | 2.59% |
| 6 | 26,488 | 930 | 3.51% |
| 7 | 8,907 | 388 | 4.36% |
| 8 | 2,252 | 89 | 3.95% |
| 9 | 378 | 22 | 5.82% |
| 10 | 65 | 8 | 12.31% |
| 11 | 9 | 2 | 22.22% |

La tasa muestra una tendencia general creciente a medida que aumenta el número de transacciones. Sin embargo, los valores altos (especialmente 8 o más) tienen pocas observaciones, por lo que sus tasas son menos estables.

Al agrupar los valores de 7 a 11 se obtienen 11,611 transacciones, 509 fraudes y una tasa de 4.38%. Este grupo representa aproximadamente el 1.66% de las operaciones y el 4.35% de los fraudes.

**Lectura:** `txn_count_last_24h` presenta una asociación descriptiva relevante. Los grupos de frecuencia alta deben interpretarse considerando su menor tamaño.

### 3.6 `velocity_score`

| Estadística | No fraude | Fraude |
|---|---:|---:|
| Media | 18.79 | 27.40 |
| Q1 | 11.30 | 19.30 |
| Mediana | 18.50 | 26.60 |
| Q3 | 25.80 | 35.00 |
| Mínimo | 0.00 | 0.00 |
| Máximo | 72.80 | 72.90 |

Los valores de `velocity_score` son superiores en las transacciones fraudulentas en las estadísticas comparadas.

| Quintil | Rango aproximado | Transacciones | Fraudes | Tasa |
|---:|---:|---:|---:|---:|
| 1 | 0–9.50 | 139,992 | 480 | 0.34% |
| 2 | 9.50–15.80 | 139,992 | 1,176 | 0.84% |
| 3 | 15.80–21.40 | 139,992 | 1,998 | 1.43% |
| 4 | 21.40–28.00 | 139,992 | 2,760 | 1.97% |
| 5 | 28.00–72.90 | 139,992 | 5,275 | 3.77% |

La tasa aumenta progresivamente entre quintiles. El quinto quintil presenta una tasa aproximadamente 11.1 veces superior a la del primero.

**Lectura:** es una de las asociaciones marginales más marcadas del EDA. No se atribuye un significado específico al score porque su definición no ha sido documentada en el análisis.

### 3.7 `cvv_retry_count`

| Reintentos | Transacciones | Fraudes | Tasa de fraude |
|---:|---:|---:|---:|
| 0 | 642,088 | 5,990 | 0.93% |
| 1 | 55,942 | 4,895 | 8.75% |
| 2 | 1,905 | 795 | 41.73% |
| 3 | 25 | 9 | 36.00% |

La tasa aumenta notablemente desde cero hasta dos reintentos. Aunque el valor 3 presenta una tasa menor que el valor 2, solo contiene 25 observaciones, por lo que no debe interpretarse como una caída estable.

Las 1,905 transacciones con dos reintentos representan aproximadamente el 0.27% de las operaciones, pero contienen 795 fraudes, cerca del 6.8% de todos los fraudes.

**Lectura:** `cvv_retry_count` muestra una asociación descriptiva muy fuerte. Los valores extremos requieren cautela por su baja frecuencia.

### 3.8 `card_age_months`

Tasas de fraude por quintiles:

| Quintil | Rango aproximado (meses) | Transacciones | Fraudes | Tasa |
|---:|---:|---:|---:|---:|
| 1 | 25–42 | 139,992 | 2,298 | 1.64% |
| 2 | 42–45 | 139,992 | 2,302 | 1.64% |
| 3 | 45–48 | 139,992 | 2,356 | 1.68% |
| 4 | 48–52 | 139,992 | 2,412 | 1.72% |
| 5 | 52–73 | 139,992 | 2,321 | 1.66% |

Las tasas son muy similares entre quintiles. No se observa una asociación marginal marcada.

### 3.9 `customer_age`

Tasas de fraude por quintiles:

| Quintil | Rango aproximado (años) | Transacciones | Fraudes | Tasa |
|---:|---:|---:|---:|---:|
| 1 | 18–33 | 139,992 | 697 | 0.50% |
| 2 | 33–47 | 139,992 | 2,043 | 1.46% |
| 3 | 47–58 | 139,992 | 2,350 | 1.68% |
| 4 | 58–69 | 139,992 | 2,648 | 1.89% |
| 5 | 69–81 | 139,992 | 3,951 | 2.82% |

La tasa aumenta a través de los quintiles, desde 0.50% hasta 2.82%. El quinto quintil presenta una tasa 5.64 veces superior a la del primero y concentra aproximadamente el 33.8% de los fraudes.

**Lectura:** se observa una asociación descriptiva marcada. Dado que se trata de una variable demográfica, su uso en un sistema real de detección requeriría una evaluación específica de equidad, pertinencia y cumplimiento normativo. El resultado observado no implica causalidad.

---

## 4. Variables booleanas

La tasa global de fraude en `train` es 1.67%. La siguiente tabla compara las tasas para los valores `false` y `true`.

| Variable | Valor | Transacciones | Fraudes | Tasa de fraude | % de todas las transacciones |
|---|---|---:|---:|---:|---:|
| `is_foreign_transaction` | false | 687,862 | 10,168 | 1.48% | — |
| `is_foreign_transaction` | true | 12,098 | 1,521 | 12.57% | 1.73% |
| `is_new_merchant` | false | 593,240 | 6,637 | 1.12% | 84.75% |
| `is_new_merchant` | true | 106,720 | 5,052 | 4.73% | 15.25% |
| `used_vpn` | false | 676,295 | 10,139 | 1.50% | 96.62% |
| `used_vpn` | true | 23,665 | 1,550 | 6.55% | 3.38% |
| `ip_country_mismatch` | false | 688,648 | 9,823 | 1.43% | 98.38% |
| `ip_country_mismatch` | true | 11,312 | 1,866 | 16.50% | 1.62% |
| `billing_shipping_mismatch` | false | 690,906 | 10,513 | 1.52% | 98.71% |
| `billing_shipping_mismatch` | true | 9,054 | 1,176 | 12.99% | 1.29% |
| `is_ai_generated_scam_attempt` | false | 697,661 | 11,339 | 1.63% | 99.67% |
| `is_ai_generated_scam_attempt` | true | 2,299 | 350 | 15.22% | 0.33% |

### 4.1 Principales observaciones

- **`is_foreign_transaction`:** las operaciones con valor `true` presentan una tasa de 12.57%, aproximadamente 7.5 veces la tasa global. Representan el 1.73% de las operaciones y concentran cerca del 13.0% de los fraudes.
- **`is_new_merchant`:** las operaciones con valor `true` presentan una tasa de 4.73%, aproximadamente 2.8 veces la tasa global. Representan el 15.25% de las operaciones y concentran cerca del 43.2% de los fraudes.
- **`used_vpn`:** las operaciones con valor `true` presentan una tasa de 6.55%, aproximadamente 3.9 veces la tasa global. Representan el 3.38% de las operaciones y concentran cerca del 13.3% de los fraudes.
- **`ip_country_mismatch`:** las operaciones con valor `true` presentan una tasa de 16.50%, aproximadamente 9.9 veces la tasa global. Representan el 1.62% de las operaciones y concentran cerca del 16.0% de los fraudes.
- **`billing_shipping_mismatch`:** las operaciones con valor `true` presentan una tasa de 12.99%, aproximadamente 7.8 veces la tasa global. Representan el 1.29% de las operaciones y concentran cerca del 10.1% de los fraudes.
- **`is_ai_generated_scam_attempt`:** las operaciones con valor `true` presentan una tasa de 15.22%, aproximadamente 9.1 veces la tasa global. Son solo el 0.33% de las operaciones y concentran cerca del 3.0% de los fraudes.

**Lectura:** estas variables presentan asociaciones marginales destacadas. Algunas condiciones son poco frecuentes, por lo que es importante considerar tanto la tasa como el volumen de operaciones y fraudes. El EDA no documenta cómo se construyeron estas variables ni permite inferir su mecanismo causal.

---

## 5. Variables categóricas

### 5.1 `merchant_category`

| Categoría | Transacciones | Fraudes | Tasa de fraude |
|---|---:|---:|---:|
| Gift Cards | 9,456 | 690 | 7.30% |
| Crypto Exchange | 5,285 | 345 | 6.53% |
| Gaming | 23,784 | 1,311 | 5.51% |
| Electronics | 48,693 | 1,501 | 3.08% |
| Streaming | 47,196 | 1,061 | 2.25% |
| Travel | 28,715 | 534 | 1.86% |
| Utilities | 42,027 | 581 | 1.38% |
| Healthcare | 35,889 | 462 | 1.29% |
| Fuel | 59,880 | 741 | 1.24% |
| Restaurants | 101,360 | 1,159 | 1.14% |
| Online Retail | 155,097 | 1,719 | 1.11% |
| Groceries | 142,578 | 1,585 | 1.11% |

Gift Cards, Crypto Exchange y Gaming presentan las tasas más altas. Sin embargo, una tasa alta no implica necesariamente el mayor número absoluto de fraudes: Online Retail registra más fraudes por su mayor volumen de transacciones.

**Lectura:** `merchant_category` puede aportar señal predictiva. Las categorías de menor frecuencia deben evaluarse teniendo en cuenta el tamaño de sus grupos.

### 5.2 `card_type`

| Tipo de tarjeta | Transacciones | Fraudes | Tasa de fraude | % de transacciones |
|---|---:|---:|---:|---:|
| Amex | 45,797 | 871 | 1.90% | 6.54% |
| Visa | 345,001 | 5,860 | 1.70% | 49.29% |
| RuPay | 37,070 | 623 | 1.68% | 5.30% |
| Mastercard | 254,857 | 4,084 | 1.60% | 36.41% |
| Discover | 17,235 | 251 | 1.46% | 2.46% |

Las tasas son relativamente cercanas. Visa tiene el mayor número absoluto de fraudes, pero también concentra el mayor volumen de transacciones.

**Lectura:** la asociación marginal parece débil; la variable podría aportar información en combinación con otras características.

### 5.3 `auth_method`

| Método de autenticación | Transacciones | Fraudes | Tasa de fraude | % de transacciones |
|---|---:|---:|---:|---:|
| No Authentication | 67,060 | 4,322 | 6.44% | 9.58% |
| 3D Secure | 210,036 | 3,098 | 1.47% | 30.01% |
| OTP | 175,178 | 2,464 | 1.41% | 25.03% |
| PIN | 154,020 | 1,337 | 0.87% | 22.00% |
| Biometric | 93,666 | 468 | 0.50% | 13.38% |

No Authentication presenta una tasa de 6.44%, aproximadamente 3.9 veces la tasa global, y concentra cerca del 37% de los fraudes pese a representar el 9.58% de las operaciones. Biometric presenta la menor tasa observada (0.50%).

**Lectura:** `auth_method` muestra una asociación descriptiva destacada. Estos resultados no prueban que un método de autenticación cause o evite fraude.

### 5.4 `channel`

| Canal | Transacciones | Fraudes | Tasa de fraude |
|---|---:|---:|---:|
| Online | 273,939 | 4,773 | 1.74% |
| POS | 206,465 | 3,428 | 1.66% |
| In-App | 83,716 | 1,367 | 1.63% |
| ATM | 30,220 | 480 | 1.59% |
| Contactless | 105,620 | 1,641 | 1.55% |

Las tasas son muy cercanas, entre 1.55% y 1.74%.

**Lectura:** no se observa una asociación marginal fuerte entre `channel` y el fraude.

### 5.5 `device_type`

| Tipo de dispositivo | Transacciones | Fraudes | Tasa de fraude |
|---|---:|---:|---:|
| POS Terminal | 113,237 | 1,958 | 1.73% |
| iPhone | 164,691 | 2,836 | 1.72% |
| Mac | 33,973 | 581 | 1.71% |
| Tablet | 27,688 | 471 | 1.70% |
| ATM Machine | 20,877 | 354 | 1.70% |
| Smart Watch | 21,106 | 359 | 1.70% |
| Windows PC | 80,934 | 1,306 | 1.61% |
| Android Phone | 237,454 | 3,824 | 1.61% |

Las tasas se mantienen en un rango estrecho, de 1.61% a 1.73%. Android Phone presenta más fraudes absolutos, pero también tiene el mayor volumen de transacciones.

**Lectura:** `device_type` muestra una asociación marginal débil en este análisis.

---

## 6. Variables temporales

### 6.1 `time_of_day_hour`

La tasa de fraude por hora oscila entre 1.44% y 1.83%. La hora 1 presenta la menor tasa (1.44%) y la hora 21 la mayor (1.83%).

Las diferencias son pequeñas y no se observa un patrón horario pronunciado.

### 6.2 `day_of_week`

| Valor de `day_of_week` | Tasa de fraude |
|---:|---:|
| 0 | 1.58% |
| 1 | 1.66% |
| 2 | 1.67% |
| 3 | 1.64% |
| 4 | 1.68% |
| 5 | 1.68% |
| 6 | 1.78% |

Las tasas varían entre 1.58% y 1.78%, con una diferencia reducida. No se ha establecido en este análisis qué día de la semana corresponde a cada valor numérico; por tanto, no se asignan nombres de días.

**Lectura conjunta:** las variables temporales examinadas presentan diferencias marginales pequeñas. No se descartan, ya que podrían adquirir valor mediante transformaciones o interacciones.

---

## 7. Análisis de interacciones

El análisis marginal considera una variable a la vez. Las interacciones permiten observar si la tasa de fraude cambia al combinar dos condiciones.

### 7.1 `is_foreign_transaction` × `ip_country_mismatch`

| Transacción extranjera | Desajuste de país IP | Transacciones | Fraudes | Tasa |
|---|---|---:|---:|---:|
| false | false | 680,081 | 9,216 | 1.36% |
| false | true | 7,781 | 952 | 12.23% |
| true | false | 8,567 | 607 | 7.09% |
| true | true | 3,531 | 914 | 25.89% |

La combinación de ambas condiciones presenta una tasa de fraude de 25.89%, superior a la observada para cada condición por separado.

**Lectura:** esta combinación es una candidata interesante para explorar como interacción durante el feature engineering. La tasa observada no demuestra causalidad.

### 7.2 `used_vpn` × `ip_country_mismatch`

| VPN | Desajuste de país IP | Transacciones | Fraudes | Tasa |
|---|---|---:|---:|---:|
| false | false | 665,571 | 8,530 | 1.28% |
| false | true | 10,724 | 1,609 | 15.00% |
| true | false | 23,077 | 1,293 | 5.60% |
| true | true | 588 | 257 | 43.71% |

La combinación de `used_vpn = true` e `ip_country_mismatch = true` presenta la tasa más alta (43.71%). Sin embargo, contiene solo 588 observaciones. Los 257 fraudes de ese grupo representan aproximadamente el 2.2% de todos los fraudes.

**Lectura:** es una interacción potencialmente informativa, pero su baja frecuencia exige cautela. Conviene comprobar si aporta mejora real mediante validación cruzada y no asumir que una tasa alta en un grupo pequeño se traducirá automáticamente en mejor rendimiento predictivo.

---

## 8. Síntesis de hallazgos

### 8.1 Variables con asociaciones descriptivas destacadas

En los análisis realizados, las siguientes variables o grupos mostraron diferencias relevantes entre transacciones fraudulentas y no fraudulentas:

- `cvv_retry_count`: la tasa aumenta marcadamente al pasar de cero a uno y dos reintentos.
- `velocity_score`: la tasa aumenta progresivamente entre quintiles.
- `txn_count_last_24h`: tendencia general de mayor tasa a mayor número de transacciones.
- `customer_age`: aumento de la tasa entre quintiles, con una diferencia marcada entre el primero y el quinto.
- `hours_since_last_txn`: mayor tasa en el quintil con intervalos más cortos.
- `is_foreign_transaction`.
- `is_new_merchant`.
- `used_vpn`.
- `ip_country_mismatch`.
- `billing_shipping_mismatch`.
- `is_ai_generated_scam_attempt`.
- `merchant_category`.
- `auth_method`.

Estas variables merecen atención en la etapa de modelado, pero esta lista no es un ranking de importancia ni una selección definitiva de características.

### 8.2 Variables con asociaciones marginales débiles o diferencias pequeñas

En los análisis univariados realizados, se observaron diferencias pequeñas o tasas relativamente uniformes para:

- `account_balance_usd`.
- `distance_from_home_km`.
- `card_age_months`.
- `card_type`.
- `channel`.
- `device_type`.
- `time_of_day_hour`.
- `day_of_week`.

No se recomienda eliminarlas únicamente por estos resultados. Podrían contribuir mediante relaciones no lineales, interacciones o combinaciones con otras variables.

### 8.3 Interacciones candidatas

Las combinaciones que merecen una evaluación específica son:

- `is_foreign_transaction` × `ip_country_mismatch`.
- `used_vpn` × `ip_country_mismatch`.

En ambos casos, las tasas combinadas son superiores a las tasas marginales. La segunda interacción tiene un grupo conjunto pequeño (588 registros), por lo que su estimación es menos estable.

---

## 9. Limitaciones e interpretación

1. **Asociación no implica causalidad.** Las tasas comparadas describen los datos observados; no explican por qué ocurre el fraude.
2. **Análisis marginal no equivale a importancia predictiva.** Una variable con diferencias pequeñas por sí sola puede ser útil en combinación con otras.
3. **No se ha evaluado rendimiento de modelos en esta fase.** La utilidad de cada característica debe comprobarse con un esquema de validación adecuado y la métrica ROC-AUC.
4. **Los grupos pequeños producen tasas menos estables.** Esto es especialmente relevante para valores altos de `cvv_retry_count`, `txn_count_last_24h` y para la interacción `used_vpn` × `ip_country_mismatch`.
5. **No se ha documentado la definición interna de todas las variables.** No se debe atribuir un significado adicional a `velocity_score` o a los indicadores booleanos más allá de sus nombres y valores observados.
6. **La codificación de `day_of_week` no se ha confirmado.** No se asignan nombres de días a sus valores.
7. **`customer_age` requiere una evaluación de equidad y pertinencia** antes de considerar su uso en un sistema real.
8. **El análisis de fraude se limita a `train`.** No se calculan tasas de fraude sobre `test`, porque no contiene la etiqueta `is_fraud`.

---

## 10. Implicaciones para las siguientes fases

Los resultados del EDA orientan, pero no predeterminan, las siguientes tareas:

1. **Feature engineering:** evaluar transformaciones no lineales y las interacciones identificadas, manteniendo una comparación con un baseline sin esas transformaciones.
2. **Codificación de variables categóricas:** definir una estrategia para `merchant_category`, `card_type`, `auth_method`, `channel` y `device_type`.
3. **Validación:** utilizar una estrategia estratificada que preserve la proporción de la clase positiva en los folds.
4. **Modelado:** comparar modelos adecuados para datos tabulares y desbalanceados.
5. **Evaluación:** utilizar ROC-AUC como métrica principal de comparación, manteniendo el mismo esquema de validación para que los resultados sean comparables.
6. **Selección de características:** decidir con evidencia obtenida en validación, no únicamente por las tasas descriptivas de este documento.

**Conclusión:** el EDA identificó señales descriptivas relevantes relacionadas con actividad transaccional, reintentos de CVV, `velocity_score`, ciertas condiciones de contexto y algunas categorías de autenticación y comercio. También reveló dos interacciones potencialmente útiles. Estos hallazgos constituyen hipótesis para el feature engineering y el modelado; su valor definitivo debe comprobarse mediante validación.
