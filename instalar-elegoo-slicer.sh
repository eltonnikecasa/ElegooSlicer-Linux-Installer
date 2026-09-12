#!/usr/bin/env bash
set -u

# ============================================================
# Instalador ElegooSlicer não oficial
# Um único .sh
# Debian/Ubuntu, Arch/CachyOS/Manjaro, Fedora/RHEL-like, openSUSE
# ============================================================

APP_NAME="ElegooSlicer"
REPO="elegooofficial/ElegooSlicer"
TITLE="Instalador ElegooSlicer não oficial"

INSTALL_DIR="$HOME/.local/opt/elegoo-slicer"
APPIMAGE="$INSTALL_DIR/ElegooSlicer.AppImage"

BIN_DIR="$HOME/.local/bin"
UNINSTALLER="$BIN_DIR/desinstalar-elegoo-slicer"

APPS_DIR="$HOME/.local/share/applications"
APP_DESKTOP="$APPS_DIR/elegoo-slicer.desktop"
UNINSTALL_DESKTOP="$APPS_DIR/desinstalar-elegoo-slicer.desktop"

ICON_ROOT="$HOME/.local/share/icons/hicolor"
APP_ICON_NAME="elegooslicerico"
APP_ICON_DIR="$ICON_ROOT/256x256/apps"
APP_ICON="$APP_ICON_DIR/$APP_ICON_NAME.png"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/elegoo-slicer-installer"
TMP_APPIMAGE="$CACHE_DIR/ElegooSlicer.download.AppImage"
EXTRACT_DIR="$CACHE_DIR/extract"

# ------------------------------------------------------------
# Detecta distribuição
# ------------------------------------------------------------

DISTRO="Linux"
PKG_MANAGER=""

if [ -r /etc/os-release ]; then
    . /etc/os-release
    DISTRO="${PRETTY_NAME:-${NAME:-Linux}}"
fi

if command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
elif command -v apt-get >/dev/null 2>&1; then
    PKG_MANAGER="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
elif command -v zypper >/dev/null 2>&1; then
    PKG_MANAGER="zypper"
else
    printf 'ERRO: gerenciador de pacotes compatível não encontrado.\n'
    exit 1
fi

install_packages() {
    case "$PKG_MANAGER" in
        pacman) sudo pacman -S --needed --noconfirm "$@" ;;
        apt)
            sudo apt-get update
            sudo apt-get install -y "$@"
            ;;
        dnf) sudo dnf install -y "$@" ;;
        zypper) sudo zypper --non-interactive install "$@" ;;
    esac
}

# ------------------------------------------------------------
# Dependências
# ------------------------------------------------------------

if ! command -v curl >/dev/null 2>&1; then
    install_packages curl || exit 1
fi

GUI=""

# Interface gráfica independente do ambiente de desktop:
# usa o que já estiver disponível no sistema.
if command -v zenity >/dev/null 2>&1; then
    GUI="zenity"
elif command -v kdialog >/dev/null 2>&1; then
    GUI="kdialog"
else
    printf '
Nenhuma interface gráfica compatível encontrada.
'
    printf 'Tentando instalar Zenity...
'

    if install_packages zenity >/dev/null 2>&1; then
        GUI="zenity"
    else
        # Fallback universal: funciona mesmo sem ambiente gráfico compatível.
        GUI="cli"
        printf 'Não foi possível instalar Zenity.
'
        printf 'O instalador continuará em modo texto.
'
    fi
fi

# ImageMagick é usado para extrair/converter resources/images/ElegooSlicer.ico para PNG.
if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
    case "$PKG_MANAGER" in
        pacman)
            install_packages imagemagick || exit 1
            ;;
        apt)
            install_packages imagemagick || exit 1
            ;;
        dnf)
            install_packages ImageMagick || exit 1
            ;;
        zypper)
            install_packages ImageMagick || exit 1
            ;;
    esac
fi

# Suporte FUSE útil para AppImage
case "$PKG_MANAGER" in
    apt)
        dpkg -s libfuse2 >/dev/null 2>&1 || \
        dpkg -s libfuse2t64 >/dev/null 2>&1 || \
        sudo apt-get install -y libfuse2t64 >/dev/null 2>&1 || \
        sudo apt-get install -y libfuse2 >/dev/null 2>&1 || true
        ;;
    pacman)
        pacman -Q fuse2 >/dev/null 2>&1 || \
        sudo pacman -S --needed --noconfirm fuse2 >/dev/null 2>&1 || true
        ;;
    dnf)
        rpm -q fuse-libs >/dev/null 2>&1 || \
        sudo dnf install -y fuse-libs >/dev/null 2>&1 || true
        ;;
    zypper)
        rpm -q libfuse2 >/dev/null 2>&1 || \
        sudo zypper --non-interactive install libfuse2 >/dev/null 2>&1 || true
        ;;
esac

# ------------------------------------------------------------
# GUI
# ------------------------------------------------------------

gui_info() {
    local text="$1"
    if [ "$GUI" = "zenity" ]; then
        zenity --info --title="$TITLE" --width=540 --text="$text" 2>/dev/null
    elif [ "$GUI" = "kdialog" ]; then
        kdialog --title "$TITLE" --msgbox "$text"
    else
        printf '
%s

' "$(printf '%s' "$text" | sed 's/<[^>]*>//g')"
    fi
}

gui_error() {
    local text="$1"
    if [ "$GUI" = "zenity" ]; then
        zenity --error --title="$TITLE" --width=540 --text="$text" 2>/dev/null
    elif [ "$GUI" = "kdialog" ]; then
        kdialog --title "$TITLE" --error "$text"
    else
        printf '
ERRO: %s

' "$(printf '%s' "$text" | sed 's/<[^>]*>//g')" >&2
    fi
}

gui_question() {
    local text="$1"
    if [ "$GUI" = "zenity" ]; then
        zenity --question --title="$TITLE" --width=560 \
            --ok-label="Sim" --cancel-label="Não" --text="$text" 2>/dev/null
    elif [ "$GUI" = "kdialog" ]; then
        kdialog --title "$TITLE" --yesno "$text" \
            --yes-label "Sim" --no-label "Não"
    else
        printf '
%s
' "$(printf '%s' "$text" | sed 's/<[^>]*>//g')"
        printf 'Continuar? [s/N]: '
        read -r answer
        [[ "$answer" =~ ^[SsYy]$ ]]
    fi
}

fail() {
    gui_error "$1"
    exit 1
}

# ------------------------------------------------------------
# Consulta GitHub
# ------------------------------------------------------------

gui_info "Distribuição detectada:

<b>$DISTRO</b>

O instalador verificará agora a versão mais recente oficial do ElegooSlicer."

API_JSON="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")" \
    || fail "Não foi possível consultar o GitHub."

LATEST_TAG="$(printf '%s' "$API_JSON" \
    | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -n1)"

[ -n "$LATEST_TAG" ] || fail "Não foi possível identificar a versão mais recente."

LATEST_VERSION="${LATEST_TAG#v}"

DOWNLOAD_URL="$(printf '%s' "$API_JSON" \
    | grep -o 'https://[^"]*\.AppImage' \
    | grep -Ei 'ElegooSlicer.*Linux|Linux.*ElegooSlicer' \
    | head -n1 || true)"

if [ -z "$DOWNLOAD_URL" ]; then
    DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/ElegooSlicer_Linux_V${LATEST_VERSION}.AppImage"
fi

if [ -f "$APPIMAGE" ]; then
    QUESTION="Versão oficial encontrada:

<b>ElegooSlicer $LATEST_VERSION</b>

Já existe uma instalação neste computador.

Deseja instalar/atualizar?"
else
    QUESTION="Versão oficial encontrada:

<b>ElegooSlicer $LATEST_VERSION</b>

Deseja instalar?"
fi

gui_question "$QUESTION" || exit 0

mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$APPS_DIR" "$APP_ICON_DIR" "$CACHE_DIR"
rm -f "$TMP_APPIMAGE"

# ------------------------------------------------------------
# Função: extrair ícone CORRETO dinamicamente
# ------------------------------------------------------------

extract_correct_icon() {
    rm -rf "$EXTRACT_DIR"
    mkdir -p "$EXTRACT_DIR"

    (
        cd "$EXTRACT_DIR" || exit 1
        "$APPIMAGE" --appimage-extract >/dev/null 2>&1
    ) || return 1

    ROOT="$EXTRACT_DIR/squashfs-root"
    [ -d "$ROOT" ] || return 1

    # Ícone correto dentro do AppImage oficial.
    ICO_FILE="$ROOT/resources/images/ElegooSlicer.ico"
    [ -f "$ICO_FILE" ] || return 1

    # Nunca reutiliza um ícone antigo.
    rm -f "$APP_ICON"

    ICON_TMP_DIR="$EXTRACT_DIR/ico-png"
    rm -rf "$ICON_TMP_DIR"
    mkdir -p "$ICON_TMP_DIR"

    # O .ico contém várias resoluções. Extraímos todas e escolhemos
    # a maior representação válida antes de normalizar para 256x256.
    if command -v magick >/dev/null 2>&1; then
        magick "$ICO_FILE" "$ICON_TMP_DIR/icon-%03d.png" >/dev/null 2>&1 || true
    elif command -v convert >/dev/null 2>&1; then
        convert "$ICO_FILE" "$ICON_TMP_DIR/icon-%03d.png" >/dev/null 2>&1 || true
    fi

    BEST_ICON=""
    BEST_AREA=0

    for candidate in "$ICON_TMP_DIR"/*.png; do
        [ -f "$candidate" ] || continue

        if command -v identify >/dev/null 2>&1; then
            read -r W H <<EOF
$(identify -format '%w %h' "$candidate" 2>/dev/null || printf '0 0')
EOF
        else
            W=0
            H=0
        fi

        case "$W:$H" in
            *[!0-9:]*|"0:0") continue ;;
        esac

        AREA=$((W * H))
        if [ "$AREA" -gt "$BEST_AREA" ]; then
            BEST_AREA="$AREA"
            BEST_ICON="$candidate"
        fi
    done

    [ -n "$BEST_ICON" ] && [ -f "$BEST_ICON" ] || return 1

    # Normaliza para 256x256 mantendo transparência.
    if command -v magick >/dev/null 2>&1; then
        magick "$BEST_ICON" \
            -background none \
            -resize 256x256 \
            -gravity center \
            -extent 256x256 \
            "$APP_ICON" >/dev/null 2>&1 || return 1
    else
        convert "$BEST_ICON" \
            -background none \
            -resize 256x256 \
            -gravity center \
            -extent 256x256 \
            "$APP_ICON" >/dev/null 2>&1 || return 1
    fi

    [ -s "$APP_ICON" ] || return 1
    return 0
}

# ------------------------------------------------------------
# Cria atalhos
# ------------------------------------------------------------

create_shortcuts() {

    cat > "$UNINSTALLER" <<'UNINSTALL_EOF'
#!/usr/bin/env bash
set -u

TITLE="Desinstalar ElegooSlicer"
INSTALL_DIR="$HOME/.local/opt/elegoo-slicer"
APPIMAGE="$INSTALL_DIR/ElegooSlicer.AppImage"
BIN_FILE="$HOME/.local/bin/desinstalar-elegoo-slicer"
APP_DESKTOP="$HOME/.local/share/applications/elegoo-slicer.desktop"
UNINSTALL_DESKTOP="$HOME/.local/share/applications/desinstalar-elegoo-slicer.desktop"
APP_ICON="$HOME/.local/share/icons/hicolor/256x256/apps/elegooslicerico.png"

GUI=""
command -v zenity >/dev/null 2>&1 && GUI="zenity"
if [ -z "$GUI" ] && command -v kdialog >/dev/null 2>&1; then GUI="kdialog"; fi
if [ -z "$GUI" ]; then GUI="cli"; fi

question() {
    if [ "$GUI" = "zenity" ]; then
        zenity --question --title="$TITLE" --width=500 \
            --ok-label="Sim" --cancel-label="Não" \
            --text="Deseja realmente desinstalar o ElegooSlicer?

Seus perfis e configurações pessoais serão preservados." 2>/dev/null
    elif [ "$GUI" = "kdialog" ]; then
        kdialog --title "$TITLE" --yesno \
            "Deseja realmente desinstalar o ElegooSlicer?

Seus perfis e configurações pessoais serão preservados."
    else
        printf 'Deseja realmente desinstalar? [s/N] '
        read -r answer
        [[ "$answer" =~ ^[SsYy]$ ]]
    fi
}

info() {
    local text="$1"
    if [ "$GUI" = "zenity" ]; then
        zenity --info --title="$TITLE" --width=500 --text="$text" 2>/dev/null
    elif [ "$GUI" = "kdialog" ]; then
        kdialog --title "$TITLE" --msgbox "$text"
    else
        printf '%s\n' "$text"
    fi
}

question || exit 0

pkill -f "$APPIMAGE" >/dev/null 2>&1 || true
pkill -f ElegooSlicer >/dev/null 2>&1 || true

rm -f "$APPIMAGE"
rm -f "$APP_DESKTOP"
rm -f "$UNINSTALL_DESKTOP"
rm -f "$APP_ICON"
rmdir "$INSTALL_DIR" 2>/dev/null || true

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 >/dev/null 2>&1 || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
    kbuildsycoca5 >/dev/null 2>&1 || true
fi

info "ElegooSlicer foi desinstalado com sucesso.

Seus perfis e configurações pessoais foram mantidos."

rm -f "$BIN_FILE"
UNINSTALL_EOF

    chmod +x "$UNINSTALLER"

    cat > "$APP_DESKTOP" <<EOF
[Desktop Entry]
Name=ElegooSlicer
Comment=Elegoo 3D Printing Slicer
Exec=$APPIMAGE %F
Icon=$APP_ICON_NAME
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;Engineering;
StartupNotify=true
MimeType=model/stl;model/3mf;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;
EOF

    chmod +x "$APP_DESKTOP"

    cat > "$UNINSTALL_DESKTOP" <<EOF
[Desktop Entry]
Name=Desinstalar ElegooSlicer
Comment=Remove o ElegooSlicer
Exec=$UNINSTALLER
Icon=user-trash
Terminal=false
Type=Application
Categories=Utility;
StartupNotify=true
EOF

    chmod +x "$UNINSTALL_DESKTOP"
}

refresh_desktop() {
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
    fi

    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -f -t "$ICON_ROOT" >/dev/null 2>&1 || true
    fi

    if command -v kbuildsycoca6 >/dev/null 2>&1; then
        kbuildsycoca6 >/dev/null 2>&1 || true
    elif command -v kbuildsycoca5 >/dev/null 2>&1; then
        kbuildsycoca5 >/dev/null 2>&1 || true
    fi
}

# ------------------------------------------------------------
# Instalação + progresso
# ------------------------------------------------------------

if [ "$GUI" = "zenity" ]; then
    (
        echo "5"
        echo "# Baixando ElegooSlicer $LATEST_VERSION..."

        curl -fL "$DOWNLOAD_URL" -o "$TMP_APPIMAGE" --silent --show-error || exit 20

        echo "65"
        echo "# Instalando AppImage..."

        chmod +x "$TMP_APPIMAGE"

        [ -f "$APPIMAGE" ] && mv "$APPIMAGE" "$APPIMAGE.bak"

        if ! mv "$TMP_APPIMAGE" "$APPIMAGE"; then
            [ -f "$APPIMAGE.bak" ] && mv "$APPIMAGE.bak" "$APPIMAGE"
            exit 21
        fi

        chmod +x "$APPIMAGE"

        echo "78"
        echo "# Extraindo o ícone correto do AppImage..."

        extract_correct_icon || exit 22

        echo "90"
        echo "# Criando atalhos..."

        create_shortcuts

        echo "97"
        echo "# Atualizando menu de aplicativos..."

        refresh_desktop

        rm -rf "$EXTRACT_DIR"
        rm -f "$APPIMAGE.bak"

        echo "100"
        echo "# Instalação concluída."
        sleep 0.5

    ) | zenity --progress \
        --title="$TITLE" \
        --width=560 \
        --percentage=0 \
        --auto-close \
        --no-cancel 2>/dev/null

    STATUS="${PIPESTATUS[0]}"

    if [ "$STATUS" -ne 0 ]; then
        rm -f "$TMP_APPIMAGE"
        if [ -f "$APPIMAGE.bak" ]; then
            rm -f "$APPIMAGE"
            mv "$APPIMAGE.bak" "$APPIMAGE"
        fi
        fail "A instalação não pôde ser concluída.

A versão anterior, se existente, foi preservada."
    fi
elif [ "$GUI" = "kdialog" ]; then
    kdialog --title "$TITLE" --passivepopup "Baixando ElegooSlicer $LATEST_VERSION..." 4

    curl -fL "$DOWNLOAD_URL" -o "$TMP_APPIMAGE" \
        || fail "Falha ao baixar o AppImage."

    chmod +x "$TMP_APPIMAGE"

    [ -f "$APPIMAGE" ] && mv "$APPIMAGE" "$APPIMAGE.bak"

    if ! mv "$TMP_APPIMAGE" "$APPIMAGE"; then
        [ -f "$APPIMAGE.bak" ] && mv "$APPIMAGE.bak" "$APPIMAGE"
        fail "Falha ao instalar o AppImage."
    fi

    chmod +x "$APPIMAGE"
    extract_correct_icon || exit 22
    create_shortcuts
    refresh_desktop

    rm -rf "$EXTRACT_DIR"
    rm -f "$APPIMAGE.bak"

else
    printf '\nBaixando ElegooSlicer %s...\n' "$LATEST_VERSION"

    curl -fL "$DOWNLOAD_URL" -o "$TMP_APPIMAGE" \
        || fail "Falha ao baixar o AppImage."

    chmod +x "$TMP_APPIMAGE"

    [ -f "$APPIMAGE" ] && mv "$APPIMAGE" "$APPIMAGE.bak"

    if ! mv "$TMP_APPIMAGE" "$APPIMAGE"; then
        [ -f "$APPIMAGE.bak" ] && mv "$APPIMAGE.bak" "$APPIMAGE"
        fail "Falha ao instalar o AppImage."
    fi

    chmod +x "$APPIMAGE"

    printf 'Extraindo ícone correto...\n'
    extract_correct_icon || fail "Falha ao extrair o ícone correto do AppImage."

    printf 'Criando atalhos...\n'
    create_shortcuts

    printf 'Atualizando menu de aplicativos...\n'
    refresh_desktop

    rm -rf "$EXTRACT_DIR"
    rm -f "$APPIMAGE.bak"
fi

gui_info "Tudo ocorreu com sucesso.

<b>ElegooSlicer $LATEST_VERSION</b> foi instalado.

• AppImage instalado
• resources/images/ElegooSlicer.ico extraído e instalado
• Atalho ElegooSlicer criado
• Atalho Desinstalar ElegooSlicer criado
• Permissões configuradas
• Menu de aplicativos atualizado"

exit 0
