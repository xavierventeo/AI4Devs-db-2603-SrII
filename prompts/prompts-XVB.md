# Prompts del ejercicio

# Setup inicial
## Levantar la base de datos según configuración del repo
docker compose up -d
docker compose ps                          # debe aparecer el servicio "db" healthy
docker compose logs db --tail=30           # opcional, comprueba que arrancó OK  

## Configuración del servidor MCP en Claude
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "postgres:LTIdbUser:D1ymf8wyQEGthFR1E9xhCq@localhost:5432/LTIdb?sslmode=disable"

# Prompts

## Prompt 1: Crear el baseline inicial de la BBDD `LTIdb` desde Prisma

Actúa durante toda esta sesión como desarrollador backend senior especializado en PostgreSQL, Prisma, modelado relacional y migraciones seguras de bases de datos en producción. Mantén este rol en todos los pasos siguientes.

Objetivo: establecer el **baseline inicial** de la base de datos local `LTIdb` a partir del `schema.prisma` y del historial de migraciones del proyecto, dejándola como punto de partida limpio y trazable para futuras migraciones.

Qué debes realizar:
- Identificar el `schema.prisma`, su `provider` y la `DATABASE_URL` configurada.
- Revisar las migraciones existentes en el proyecto.
- Comprobar el estado actual de la base de datos `LTIdb` y detectar si ya está inicializada por Prisma o si está vacía.
- Materializar en la base de datos `LTIdb` el estado descrito por el schema y las migraciones.
- Validar mediante MCP que tablas, claves foráneas, índices y el registro interno de migraciones quedan coherentes con el schema.
- Reportar cualquier drift o inconsistencia antes de continuar; no realizar acciones destructivas sin confirmación.
- No modificar `schema.prisma` ni crear nuevas migraciones en este paso.

Resultado esperado: descripción del baseline establecido, migraciones registradas, estructura resultante en `LTIdb` y veredicto de alineación schema ↔ BBDD.

## Prompt 2: Ampliar el modelo a partir del ERD

Analiza el modelo actual en `backend/prisma/schema.prisma` y propón cómo ampliarlo para cubrir el siguiente ERD.

ERD del ejercicio:

erDiagram
     COMPANY {
         int id PK
         string name
     }
     EMPLOYEE {
         int id PK
         int company_id FK
         string name
         string email
         string role
         boolean is_active
     }
     POSITION {
         int id PK
         int company_id FK
         int interview_flow_id FK
         string title
         text description
         string status
         boolean is_visible
         string location
         text job_description
         text requirements
         text responsibilities
         numeric salary_min
         numeric salary_max
         string employment_type
         text benefits
         text company_description
         date application_deadline
         string contact_info
     }
     INTERVIEW_FLOW {
         int id PK
         string description
     }
     INTERVIEW_STEP {
         int id PK
         int interview_flow_id FK
         int interview_type_id FK
         string name
         int order_index
     }
     INTERVIEW_TYPE {
         int id PK
         string name
         text description
     }
     CANDIDATE {
         int id PK
         string firstName
         string lastName
         string email
         string phone
         string address
     }
     APPLICATION {
         int id PK
         int position_id FK
         int candidate_id FK
         date application_date
         string status
         text notes
     }
     INTERVIEW {
         int id PK
         int application_id FK
         int interview_step_id FK
         int employee_id FK
         date interview_date
         string result
         int score
         text notes
     }

     COMPANY ||--o{ EMPLOYEE : employs
     COMPANY ||--o{ POSITION : offers
     POSITION ||--|| INTERVIEW_FLOW : assigns
     INTERVIEW_FLOW ||--o{ INTERVIEW_STEP : contains
     INTERVIEW_STEP ||--|| INTERVIEW_TYPE : uses
     POSITION ||--o{ APPLICATION : receives
     CANDIDATE ||--o{ APPLICATION : submits
     APPLICATION ||--o{ INTERVIEW : has
     INTERVIEW ||--|| INTERVIEW_STEP : consists_of
     EMPLOYEE ||--o{ INTERVIEW : conducts

No modifiques archivos todavía. Reutiliza siempre las entidades ya existentes y no dupliques tablas que ya estén modeladas. Primero explícame:
- cómo encaja el ERD con el modelo actual
- si hay conflictos de nombres o entidades existentes reutilizables
- qué entidades nuevas crearías
- qué relaciones serían obligatorias u opcionales
- qué índices y constraints añadirías
- qué decisiones de normalización aplicarías que indique el ERD
- qué modificaciones de campos o acciones destructivas implicaría la ampliación sobre el modelo actual

---

### Claude me pregunta

 Decisiones que necesito confirmar antes de implementar
  
  1. Cardinalidad real de las tres relaciones marcadas ||--|| en el ERD: ¿N:1 (recomendado) o 1:1 literal?
  2. Enums vs String para status, employment_type, result: ¿enums tipados o respeto literal del ERD?
  3. Position.interviewFlowId y Interview.employeeId: ¿obligatorios u opcionales (recomiendo opcionales)?
  4. Employee.email: ¿único global o único por empresa?
  5. Política GDPR del borrado en Candidate → Application: RESTRICT + soft-delete, o CASCADE?
  6. Incluir en la misma migración los índices retroactivos sobre Education/WorkExperience/Resume.candidateId?

  Si me confirmas (o me dices "usa tus recomendaciones por defecto"), procedo a redactar el schema.prisma ampliado y la migración correspondiente sin tocar archivos hasta el visto bueno.

## Prompt 3: Decisiones a las preguntas de Claude
Usa estas decisiones para implementar el schema.prisma ampliado y la migración:

1. Las relaciones son N:1 (catálogos reutilizables): Position → InterviewFlow, InterviewStep → InterviewType e Interview → InterviewStep .

2. Usa enums tipados en Prisma:

* Position.status: DRAFT, OPEN, CLOSED, ARCHIVED (default: DRAFT)
* Position.employmentType: FULL_TIME, PART_TIME, CONTRACT, INTERNSHIP (sin default)
* Application.status: SUBMITTED, IN_REVIEW, INTERVIEWING, OFFERED, HIRED, REJECTED, WITHDRAWN (default: SUBMITTED)
* Interview.result: PENDING, PASSED, FAILED, NO_SHOW (default: PENDING)

3. Opcionalidad:

* Position.interviewFlowId → opcional. Será obligatorio a nivel de negocio cuando status != DRAFT.
* Interview.employeeId → obligatorio desde creación.

4. Employee.email debe ser único global.

5. Candidate → Application: usar RESTRICT + soft-delete para GDPR. No CASCADE.

6. No añadas todavía índices retroactivos sobre Education/WorkExperience/Resume.candidateId.

Con esto, procede a redactar el schema.prisma ampliado y la migración correspondiente sin tocar archivos hasta el visto bueno.

