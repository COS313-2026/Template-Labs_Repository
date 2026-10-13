# Lab 7 Solutions

**Student Name:** [Your Name]  
**Student ID:** [Your ID]  
**Date:** [Date]  

---

## Ticket 1: The Visual Audit (Physical ERD)
*Complete the physical architecture diagram below. Refer to `MERMAID_CHEAT_SHEET.md` and Ticket 1 in `IN_CLASS_LAB.md` for attribute details.*

```mermaid
erDiagram
    users {
        varchar email PK
        varchar first_name
        %% TODO: Add last_name, phone, birthdate, parent_email
    }
    teams {
        varchar team_name PK
        %% TODO: Add age_group
    }
    registrations {
        serial registration_id PK
        varchar user_email FK
        varchar team_name FK
        %% TODO: Add assigned_role, fee_amount
    }

    users ||--o{ registrations : "registers for"
    teams ||--o{ registrations : "has"

    %% TODO: Define the gear_orders entity (order_id PK, registration_id FK, gear_item, gear_size, gear_quantity)
    %% TODO: Connect registrations to gear_orders (1-to-many: ||--o{ "includes")

```
