# QueenChat coturn deployment

The root `.env` must contain these server-side values before starting coturn:

```dotenv
TURN_SHARED_SECRET=generate_a_unique_32_byte_or_longer_secret
TURN_HOST=turn.queenchat.ru
TURN_CREDENTIAL_TTL_SECONDS=3600
```

`TURN_SHARED_SECRET` is deliberately not a Vite variable and must never be
committed or copied into client assets. The current configuration publishes
3478 over UDP/TCP and relay UDP ports 49160-49220. TLS on 5349 is intentionally
deferred until the `turn.queenchat.ru` DNS record and certificate are available.
