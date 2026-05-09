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

