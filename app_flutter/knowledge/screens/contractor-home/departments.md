# _Departments

- **screen:** `contractor-home`
- **role:** section · section `categories`

## עצם · object (1)

- **text** "מחלקות"

## חיבורים · connections (3)

- **gated-by** · `const-flag` → `kProfileRawShell`
- **writes** · `state=` → `homeDepartmentProvider`
- **writes** · `state=` → `mainTabProvider`

## התנהגות · behaviour (3)

- **build** → _rule_ `if (kProfileRawShell)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `ref.read(homeDepartmentProvider.notifier).state = d.name` → write → homeDepartmentProvider
- **onTap** → _verb_ `ref.read(mainTabProvider.notifier).state = 1` → write → mainTabProvider

## floor · external functions (1)

- `cfgRadius`
