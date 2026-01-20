# Short Video Maker MCP Setup for Windows

## Prerequisites Installed
- [x] WSL with Ubuntu distribution
- [x] Docker Desktop v4.56.0
- [ ] System restart required

## Post-Restart Steps

### 1. Start Docker Desktop
After restart, Docker Desktop should auto-start. If not:
```
Start Menu → Docker Desktop
```

### 2. Verify Docker Works
```bash
docker --version
docker run hello-world
```

### 3. Pull Short Video Maker Image
```bash
docker pull gyoridavid/short-video-maker:latest
```

### 4. Configure Claude Code MCP

Add to your MCP servers configuration (settings.local.json or equivalent):

```json
{
  "mcpServers": {
    "short-video-maker": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-v", "C:/Users/lanitaEmperadora/videos:/app/output",
        "gyoridavid/short-video-maker:latest"
      ],
      "env": {}
    }
  }
}
```

### Alternative: Using npx via WSL
```json
{
  "mcpServers": {
    "short-video-maker": {
      "command": "wsl",
      "args": [
        "npx",
        "-y",
        "short-video-maker"
      ]
    }
  }
}
```

## Creating the Video

### MCP Tools Available
- `create-short-video` - Main tool for video creation
- `get-video-status` - Check video generation status

### Video Creation Prompt
```
Create a 2 minute 37 second educational video about software architecture.

Topic: "The Wrapper Trap" - why wrapping powerful frameworks unnecessarily is bad architecture.

Key points:
1. We made 54 tools wrapping Playwright when Playwright MCP already had everything
2. Adding wrappers creates: extra latency, maintenance burden, points of failure
3. The solution: Use Playwright MCP directly for study, Node.js batch scripts for extraction
4. Result: 56 articles extracted in 3 minutes with 100% success rate

Style: Fast-paced, educational, with ASCII art diagrams shown as text overlays.

Voice: Confident, slightly playful tech educator tone.

Background: Dark theme with code/terminal aesthetic.

Music: Energetic electronic (like video game OST - The End of 1000 Years).

End with: "Don't wrap powerful frameworks unnecessarily. Playwright MCP + Batch Scripts = KING"
```

## Output Location
Videos will be saved to:
`C:\Users\lanitaEmperadora\videos\`

## Troubleshooting

### Docker not starting
```bash
# Check WSL status
wsl --status

# Update WSL if needed
wsl --update
```

### Permission issues
Ensure Docker Desktop has file sharing enabled for the output directory.

## References
- [Short Video Maker GitHub](https://github.com/gyoridavid/short-video-maker)
- [Docker Hub](https://hub.docker.com/r/gyoridavid/short-video-maker)
