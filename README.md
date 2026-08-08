
# FishLog

Высоконагруженная информационная система и кластеризованная база данных для логирования рыболовных сессий, анализа биоресурсов, ведения учета инвентаря и погодных условий.

---

## Архитектура и Инфраструктура


```text
                     ┌──────────────────┐
                     │     HAProxy      │
                     │  (Load Balancer) │
                     └────────┬─────────┘
                              │
               ┌──────────────┴──────────────┐
     Write (5432)                          Read (5433)
               │                             │
               ▼                             ▼
      ┌─────────────────┐           ┌─────────────────┐
      │  pg1 (Master)   │           │  pg2 / pg3      │
      │  Patroni Node   │◄─────────►│  Replicas       │
      └────────┬────────┘           └────────┬────────┘
               │                             │
               └──────────────┬──────────────┘
                              │
                      ┌───────▼───────┐
                      │  etcd Cluster │
                      │  (DCS 3 nodes)│
                      └───────────────┘
```

### Ключевые компоненты инфраструктуры:
* **Patroni + etcd**
* **HAProxy**
* **MinIO + Automated Backup**
* **Golang Migrate**
* **Prometheus & Grafana**

---

##  Оптимизация производительности (Database Tuning)

В проекте проведен комплекс работ по профилированию и оптимизации производительности SQL:

1. **Индексация и Covering Indexes**:
2. **Оптимизация аналитических запросов**:
3. **Materialized Views**:
4. **Автоматическое сравнение планов (pgcompare)**:

---

##  Быстрый запуск

### 1. Требования
* Docker & Docker Compose
* Python 3.10+ (для генерации тестовых данных)

### 2. Запуск кластера и сервисов
```bash
docker-compose up -d
```

### 3. Применение миграций
```bash
docker compose run --rm -it --entrypoint sh migrator
export DB_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@haproxy:5432/${POSTGRES_DB}?sslmode=disable"
migrate -path /app/migrations -database "$DB_URL" up
```

### 4. Генерация сид-данных
```bash
python scripts/seed.py
```

### 5. Доступ к интерфейсам
* **HAProxy Admin / Stats**: `http://localhost:7000`
* **Grafana Dashboards**: `http://localhost:3000` (Postgres & MinIO metrics)
* **MinIO Console**: `http://localhost:9001`

---

##  Структура проекта

```text
├── migrations/          # SQL-миграции (000001 - 000007)
├── haproxy/             # Конфигурация балансировщика трафика
├── prometheus/          # Конфигурация сбора метрик
├── grafana/             # Готовые дашборды и провижининг
├── scripts/             # Скрипты бекапирования, сидинга  и инициализации
├── Dockerfile.patroni   # Образ HA-ноды PostgreSQL + Patroni
├── Dockerfile.backup    # Образ автоматического бекапирования в S3
├── docker-compose.yml   # Полный оркестратор кластера
├── queries_before.sql   # SQL запросы до оптимизации
├── queries_after.sql    # Оптимизированные SQL запросы с LATERAL/Индексами
└── schema.dbml          # Логическая схема базы данных 
```
