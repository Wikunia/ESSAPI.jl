# ESSAPI.jl

## Structure

```mermaid
flowchart TD
A[Strava] -->|websocket| B[ESS API]
B -->|PUT| A
B -->|EXEC| C[Osmosis]
B -->|EXEC| D[Tilemaker]

E[Overlay]
F[Basemap]

B -->|Restart| E
```