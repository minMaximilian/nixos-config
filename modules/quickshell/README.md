# Quickshell Configuration

A clean, modular quickshell configuration using the proven architecture pattern for maintainable UI applications.

## 📁 Project Structure

```
modules/quickshell/
├── assets/                    # Static resources (icons, themes)
│   └── Icons.qml             # Font Awesome icon constants
├── config/                   # Configuration and theming
│   ├── qmldir                # QML module definition
│   └── Theme.qml             # Stylix color integration (generated)
├── modules/                  # Main UI features/components  
│   ├── Workspaces.qml        # Workspace switcher
│   ├── Clock.qml             # Time display
│   ├── WindowTitle.qml       # Current window info
│   ├── Battery.qml           # Battery status (placeholder)
│   └── Volume.qml            # Audio control (placeholder)
├── services/                 # System integrations (future)
├── utils/                    # Shared utilities (future)
├── widgets/                  # Reusable UI components
│   ├── IconText.qml          # Icon + text display
│   └── WorkspaceButton.qml   # Interactive workspace button
├── shell.qml                 # Main entry point
├── default.nix               # Nix configuration
└── README.md                 # This file
```

## 🎯 Current Features

- **Vertical Sidebar Layout**: Clean 48px wide panel on the left side
- **Interactive Workspaces**: Click any workspace (1-12) to switch, with hover animations
- **Window Title Display**: Shows current focused window title
- **Clock Widget**: Time display with icon
- **Stylix Integration**: Automatic theming from your system color scheme
- **Modular Architecture**: Easy to extend and maintain

## 🔧 Architecture Principles

### Component Communication
```
User Input → Module → Service (future) → System
```

### File Organization
- **`assets/`**: Static resources that don't contain business logic
- **`config/`**: Theme and configuration with stylix integration  
- **`modules/`**: Self-contained UI features
- **`widgets/`**: Reusable UI components used across modules
- **`services/`**: System integrations and data providers (planned)

### Adding New Features

1. **New Widget**: Create reusable component in `widgets/`
2. **New Module**: Create feature module in `modules/` using existing widgets
3. **New Service**: Add system integration in `services/`
4. **Update Shell**: Import and use new module in `shell.qml`
5. **Update Nix**: Add file deployment in `default.nix`

## 📝 Usage

### Enable in your configuration:
```nix
myOptions.quickshell.enable = true;
```

### Manual restart:
```bash
pkill quickshell && quickshell --path ~/.config/quickshell
```

### Keybinding restart (if configured):
`Super + Ctrl + R`

## 🚀 Planned Extensions

### High Priority
- [ ] Battery monitoring widget
- [ ] Volume control widget  
- [ ] Network status indicator
- [ ] Bluetooth status

### Future Enhancements
- [ ] System resource monitoring (CPU, memory)
- [ ] Notification center
- [ ] Power menu
- [ ] Application launcher integration

## 🎨 Customization

All theming is handled automatically through stylix. Colors are injected into `config/Theme.qml` during build.

To modify layout or add widgets:
1. Edit the relevant module in `modules/`
2. Create new widgets in `widgets/` if needed
3. Update `shell.qml` to include your changes
4. Rebuild your NixOS configuration

## 🔍 Debugging

- **Verbose output**: `quickshell --path ~/.config/quickshell --verbose`
- **Check logs**: `~/.cache/quickshell/logs/`
- **QML inspector**: Available in quickshell development builds

## 📚 References

- [Quickshell Documentation](https://quickshell.outfoxxed.me/)
- [QML Reference](https://doc.qt.io/qt-6/qmlreference.html)
- [Clean Architecture Pattern](https://github.com/caelestia-shell/caelestia)

---

This configuration follows clean architecture principles for maximum maintainability and extensibility. Each component has a single responsibility and clear boundaries. 