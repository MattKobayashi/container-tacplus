# container-tacplus

A containerised TACACS+ daemon based on [`tac_plus-ng`](https://github.com/MarcJHuber/event-driven-servers).

## Usage

### Docker Compose

```yaml
services:
  tacplus:
    image: ghcr.io/mattkobayashi/tacplus:latest
    ports:
      - "49:49/tcp"
    environment:
      - TACPLUS_CFG_FILE=/opt/tac_plus-ng.cfg
    volumes:
      - ./tac_plus-ng.cfg:/opt/tac_plus-ng.cfg:ro
```

### Environment Variables

| Variable | Description | Default |
| --- | --- | --- |
| `TACPLUS_CFG_FILE` | Path to the `tac_plus-ng` configuration file. | `/opt/tac_plus-ng.cfg` |

## Configuration

The daemon is configured using the `tac_plus-ng` configuration format. See the [official documentation](https://projects.pro-bono-publico.de/event-driven-servers/doc/tac_plus-ng.html) for more information.

## License

This project is licensed under the MIT License.
