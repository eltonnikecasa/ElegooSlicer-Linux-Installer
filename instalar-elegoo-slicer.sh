#!/usr/bin/env bash
set -u

# ============================================================
# Instalador / Launcher ElegooSlicer não oficial
# Um único .sh
# Debian/Ubuntu, Arch/CachyOS/Manjaro, Fedora/RHEL-like, openSUSE
#
# Modos:
#   sem argumento  -> instalar / atualizar / reinstalar
#   --launch       -> verificar atualização silenciosamente e abrir
#   --update       -> abrir manutenção/atualização
#   --uninstall    -> desinstalar
# ============================================================

APP_NAME="ElegooSlicer"
REPO="elegooofficial/ElegooSlicer"
TITLE="Instalador ElegooSlicer não oficial"

INSTALL_DIR="$HOME/.local/opt/elegoo-slicer"
APPIMAGE="$INSTALL_DIR/ElegooSlicer.AppImage"
VERSION_FILE="$INSTALL_DIR/VERSION"

BIN_DIR="$HOME/.local/bin"
LAUNCHER="$BIN_DIR/elegoo-slicer"

APPS_DIR="$HOME/.local/share/applications"
APP_DESKTOP="$APPS_DIR/elegoo-slicer.desktop"
MAINT_DESKTOP="$APPS_DIR/atualizar-elegoo-slicer.desktop"
UNINSTALL_DESKTOP="$APPS_DIR/desinstalar-elegoo-slicer.desktop"

ICON_ROOT="$HOME/.local/share/icons/hicolor"
APP_ICON_NAME="elegooslicerico"
APP_ICON_DIR="$ICON_ROOT/256x256/apps"
APP_ICON="$APP_ICON_DIR/$APP_ICON_NAME.png"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/elegoo-slicer-installer"
TMP_APPIMAGE="$CACHE_DIR/ElegooSlicer.download.AppImage"
EXTRACT_DIR="$CACHE_DIR/extract"

MODE="${1:-install}"
if [ "$#" -gt 0 ]; then shift; fi
OPEN_ARGS=("$@")

# ------------------------------------------------------------
# GUI leve (não instala dependências no --launch)
# ------------------------------------------------------------

GUI=""
command -v zenity >/dev/null 2>&1 && GUI="zenity"
if [ -z "$GUI" ] && command -v kdialog >/dev/null 2>&1; then GUI="kdialog"; fi
[ -n "$GUI" ] || GUI="cli"

gui_info() {
    local text="$1"
    if [ "$GUI" = "zenity" ]; then
        zenity --info --title="$TITLE" --width=540 --text="$text" 2>/dev/null
    elif [ "$GUI" = "kdialog" ]; then
        kdialog --title "$TITLE" --msgbox "$text"
    else
        printf '\n%s\n\n' "$(printf '%s' "$text" | sed 's/<[^>]*>//g')"
    fi
}

gui_error() {
    local text="$1"
    if [ "$GUI" = "zenity" ]; then
        zenity --error --title="$TITLE" --width=540 --text="$text" 2>/dev/null
    elif [ "$GUI" = "kdialog" ]; then
        kdialog --title "$TITLE" --error "$text"
    else
        printf '\nERRO: %s\n\n' "$(printf '%s' "$text" | sed 's/<[^>]*>//g')" >&2
    fi
}

gui_question() {
    local text="$1"
    local yes="${2:-Sim}"
    local no="${3:-Não}"
    if [ "$GUI" = "zenity" ]; then
        zenity --question --title="$TITLE" --width=560 \
            --ok-label="$yes" --cancel-label="$no" --text="$text" 2>/dev/null
    elif [ "$GUI" = "kdialog" ]; then
        kdialog --title "$TITLE" --yesno "$text" \
            --yes-label "$yes" --no-label "$no"
    else
        printf '\n%s\n' "$(printf '%s' "$text" | sed 's/<[^>]*>//g')"
        printf '%s? [s/N]: ' "$yes"
        read -r answer
        [[ "$answer" =~ ^[SsYy]$ ]]
    fi
}

fail() {
    gui_error "$1"
    exit 1
}

installed_version() {
    if [ -s "$VERSION_FILE" ]; then
        tr -d '[:space:]' < "$VERSION_FILE"
    else
        printf ''
    fi
}

# Consulta rápida. No launcher, falha deve ser silenciosa.
get_latest_release() {
    local timeout="${1:-15}"
    command -v curl >/dev/null 2>&1 || return 1

    API_JSON="$(curl --connect-timeout "$timeout" --max-time "$timeout" -fsSL \
        "https://api.github.com/repos/$REPO/releases/latest")" || return 1

    LATEST_TAG="$(printf '%s' "$API_JSON" \
        | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
        | head -n1)"
    [ -n "$LATEST_TAG" ] || return 1

    LATEST_VERSION="${LATEST_TAG#v}"

    DOWNLOAD_URL="$(printf '%s' "$API_JSON" \
        | grep -o 'https://[^"]*\.AppImage' \
        | grep -Ei 'ElegooSlicer.*Linux|Linux.*ElegooSlicer' \
        | head -n1 || true)"

    if [ -z "$DOWNLOAD_URL" ]; then
        DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/ElegooSlicer_Linux_V${LATEST_VERSION}.AppImage"
    fi
    return 0
}

run_app() {
    [ -x "$APPIMAGE" ] || {
        gui_error "O ElegooSlicer não está instalado corretamente."
        exit 1
    }
    exec "$APPIMAGE" "${OPEN_ARGS[@]}"
}

# ------------------------------------------------------------
# MODO --launch
# ------------------------------------------------------------

if [ "$MODE" = "--launch" ]; then
    [ -f "$APPIMAGE" ] || {
        # Se o atalho existir mas a instalação não, abre manutenção.
        exec "$LAUNCHER" --update
    }

    CURRENT_VERSION="$(installed_version)"

    # 3 segundos no máximo. Sem internet/API: abre normalmente.
    if get_latest_release 3; then
        if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
            if gui_question "Nova versão do ElegooSlicer disponível.

Versão instalada: <b>$CURRENT_VERSION</b>
Nova versão: <b>$LATEST_VERSION</b>

Deseja atualizar agora?" "Atualizar" "Agora não"; then
                # Preserva arquivos que o usuário tentou abrir.
                "$LAUNCHER" --update
            fi
        fi
    fi

    run_app
fi

# ------------------------------------------------------------
# MODO --uninstall
# ------------------------------------------------------------

if [ "$MODE" = "--uninstall" ]; then
    [ -f "$APPIMAGE" ] || {
        gui_info "O ElegooSlicer não está instalado."
        exit 0
    }

    gui_question "Deseja realmente desinstalar o ElegooSlicer?

Seus perfis e configurações pessoais serão preservados." "Desinstalar" "Cancelar" || exit 0

    pkill -f "$APPIMAGE" >/dev/null 2>&1 || true
    pkill -f ElegooSlicer >/dev/null 2>&1 || true

    rm -f "$APPIMAGE" "$VERSION_FILE"
    rm -f "$APP_DESKTOP" "$MAINT_DESKTOP" "$UNINSTALL_DESKTOP"
    rm -f "$APP_ICON"
    rmdir "$INSTALL_DIR" 2>/dev/null || true

    command -v update-desktop-database >/dev/null 2>&1 && \
        update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
    command -v gtk-update-icon-cache >/dev/null 2>&1 && \
        gtk-update-icon-cache -f -t "$ICON_ROOT" >/dev/null 2>&1 || true
    command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 >/dev/null 2>&1 || true
    command -v kbuildsycoca5 >/dev/null 2>&1 && kbuildsycoca5 >/dev/null 2>&1 || true

    gui_info "ElegooSlicer foi desinstalado com sucesso.

Seus perfis e configurações pessoais foram mantidos."

    rm -f "$LAUNCHER"
    exit 0
fi

case "$MODE" in
    install|--update) ;;
    *)
        printf 'Uso: %s [--launch|--update|--uninstall] [arquivos...]\n' "$0" >&2
        exit 2
        ;;
esac

# ------------------------------------------------------------
# Detecta distribuição e dependências (somente manutenção)
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
    fail "Gerenciador de pacotes compatível não encontrado."
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

if ! command -v curl >/dev/null 2>&1; then
    install_packages curl || exit 1
fi

if [ "$GUI" = "cli" ]; then
    if install_packages zenity >/dev/null 2>&1; then
        GUI="zenity"
    fi
fi

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
    case "$PKG_MANAGER" in
        pacman|apt|zypper) install_packages imagemagick || exit 1 ;;
        dnf) install_packages ImageMagick || exit 1 ;;
    esac
fi

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
# Consulta e decisão Instalar / Atualizar / Reinstalar
# ------------------------------------------------------------

get_latest_release 15 || fail "Não foi possível consultar o GitHub."

CURRENT_VERSION="$(installed_version)"

if [ ! -f "$APPIMAGE" ]; then
    QUESTION="Versão oficial encontrada:

<b>ElegooSlicer $LATEST_VERSION</b>

O ElegooSlicer ainda não está instalado.

Deseja instalar?"
    YES_LABEL="Instalar"
elif [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    QUESTION="ElegooSlicer

Versão instalada: <b>$CURRENT_VERSION</b>
Versão disponível: <b>$LATEST_VERSION</b>

Você já possui a versão mais recente.

Deseja reinstalar esta versão?"
    YES_LABEL="Reinstalar"
elif [ -n "$CURRENT_VERSION" ]; then
    QUESTION="Atualização disponível

Versão instalada: <b>$CURRENT_VERSION</b>
Versão disponível: <b>$LATEST_VERSION</b>

Deseja atualizar o ElegooSlicer?"
    YES_LABEL="Atualizar"
else
    QUESTION="ElegooSlicer

Foi encontrada uma instalação existente, mas a versão instalada não está registrada.

Versão oficial disponível: <b>$LATEST_VERSION</b>

Deseja instalar esta versão sobre a instalação atual?"
    YES_LABEL="Atualizar"
fi

gui_question "$QUESTION" "$YES_LABEL" "Cancelar" || exit 0

mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$APPS_DIR" "$APP_ICON_DIR" "$CACHE_DIR"
rm -f "$TMP_APPIMAGE"

# ------------------------------------------------------------
# Ícone
# ------------------------------------------------------------

extract_correct_icon() {
    rm -rf "$EXTRACT_DIR"
    mkdir -p "$EXTRACT_DIR"

    (
        cd "$EXTRACT_DIR" || exit 1
        "$APPIMAGE" --appimage-extract >/dev/null 2>&1
    ) || return 1

    local ROOT="$EXTRACT_DIR/squashfs-root"
    [ -d "$ROOT" ] || return 1

    local ICO_FILE="$ROOT/resources/images/ElegooSlicer.ico"
    [ -f "$ICO_FILE" ] || return 1

    rm -f "$APP_ICON"

    local ICON_TMP_DIR="$EXTRACT_DIR/ico-png"
    rm -rf "$ICON_TMP_DIR"
    mkdir -p "$ICON_TMP_DIR"

    if command -v magick >/dev/null 2>&1; then
        magick "$ICO_FILE" "$ICON_TMP_DIR/icon-%03d.png" >/dev/null 2>&1 || true
    else
        convert "$ICO_FILE" "$ICON_TMP_DIR/icon-%03d.png" >/dev/null 2>&1 || true
    fi

    local BEST_ICON=""
    local BEST_AREA=0
    local W H AREA candidate

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

    if command -v magick >/dev/null 2>&1; then
        magick "$BEST_ICON" -background none -resize 256x256 \
            -gravity center -extent 256x256 "$APP_ICON" >/dev/null 2>&1 || return 1
    else
        convert "$BEST_ICON" -background none -resize 256x256 \
            -gravity center -extent 256x256 "$APP_ICON" >/dev/null 2>&1 || return 1
    fi

    [ -s "$APP_ICON" ]
}

# ------------------------------------------------------------
# Instala cópia do próprio script + atalhos
# ------------------------------------------------------------

install_launcher_copy() {
    local SOURCE
    SOURCE="$(readlink -f "$0" 2>/dev/null || printf '%s' "$0")"

    # Quando já estamos executando a cópia instalada, não copiamos sobre ela.
    if [ "$SOURCE" != "$LAUNCHER" ]; then
        cp "$SOURCE" "$LAUNCHER" || return 1
    fi
    chmod +x "$LAUNCHER"
}

create_shortcuts() {
    cat > "$APP_DESKTOP" <<EOF
[Desktop Entry]
Name=ElegooSlicer
Comment=Elegoo 3D Printing Slicer
Exec=$LAUNCHER --launch %F
Icon=$APP_ICON_NAME
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;Engineering;
StartupNotify=true
MimeType=model/stl;model/3mf;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;
EOF
    chmod +x "$APP_DESKTOP"

    cat > "$MAINT_DESKTOP" <<EOF
[Desktop Entry]
Name=Atualizar ElegooSlicer
Comment=Instalar, atualizar ou reinstalar o ElegooSlicer
Exec=$LAUNCHER --update
Icon=$APP_ICON_NAME
Terminal=false
Type=Application
Categories=Utility;
StartupNotify=true
EOF
    chmod +x "$MAINT_DESKTOP"

    cat > "$UNINSTALL_DESKTOP" <<EOF
[Desktop Entry]
Name=Desinstalar ElegooSlicer
Comment=Remove o ElegooSlicer
Exec=$LAUNCHER --uninstall
Icon=user-trash
Terminal=false
Type=Application
Categories=Utility;
StartupNotify=true
EOF
    chmod +x "$UNINSTALL_DESKTOP"
}

refresh_desktop() {
    command -v update-desktop-database >/dev/null 2>&1 && \
        update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
    command -v gtk-update-icon-cache >/dev/null 2>&1 && \
        gtk-update-icon-cache -f -t "$ICON_ROOT" >/dev/null 2>&1 || true
    command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 >/dev/null 2>&1 || true
    command -v kbuildsycoca5 >/dev/null 2>&1 && kbuildsycoca5 >/dev/null 2>&1 || true
}

# ------------------------------------------------------------
# Instalação
# ------------------------------------------------------------

perform_install() {
    curl -fL "$DOWNLOAD_URL" -o "$TMP_APPIMAGE" --silent --show-error || return 20
    chmod +x "$TMP_APPIMAGE"

    [ -f "$APPIMAGE" ] && mv "$APPIMAGE" "$APPIMAGE.bak"

    if ! mv "$TMP_APPIMAGE" "$APPIMAGE"; then
        [ -f "$APPIMAGE.bak" ] && mv "$APPIMAGE.bak" "$APPIMAGE"
        return 21
    fi

    chmod +x "$APPIMAGE"

    if ! extract_correct_icon; then
        rm -f "$APPIMAGE"
        [ -f "$APPIMAGE.bak" ] && mv "$APPIMAGE.bak" "$APPIMAGE"
        return 22
    fi

    printf '%s\n' "$LATEST_VERSION" > "$VERSION_FILE" || return 23
    install_launcher_copy || return 24
    create_shortcuts || return 25
    refresh_desktop

    rm -rf "$EXTRACT_DIR"
    rm -f "$APPIMAGE.bak"
    return 0
}

if [ "$GUI" = "zenity" ]; then
    (
        echo "5";  echo "# Baixando ElegooSlicer $LATEST_VERSION..."
        curl -fL "$DOWNLOAD_URL" -o "$TMP_APPIMAGE" --silent --show-error || exit 20

        echo "65"; echo "# Instalando AppImage..."
        chmod +x "$TMP_APPIMAGE"
        [ -f "$APPIMAGE" ] && mv "$APPIMAGE" "$APPIMAGE.bak"
        if ! mv "$TMP_APPIMAGE" "$APPIMAGE"; then
            [ -f "$APPIMAGE.bak" ] && mv "$APPIMAGE.bak" "$APPIMAGE"
            exit 21
        fi
        chmod +x "$APPIMAGE"

        echo "78"; echo "# Extraindo o ícone correto..."
        extract_correct_icon || exit 22

        echo "86"; echo "# Registrando versão $LATEST_VERSION..."
        printf '%s\n' "$LATEST_VERSION" > "$VERSION_FILE" || exit 23

        echo "91"; echo "# Instalando launcher..."
        install_launcher_copy || exit 24

        echo "95"; echo "# Criando atalhos..."
        create_shortcuts || exit 25

        echo "98"; echo "# Atualizando menu de aplicativos..."
        refresh_desktop

        rm -rf "$EXTRACT_DIR"
        rm -f "$APPIMAGE.bak"

        echo "100"; echo "# Concluído."
        sleep 0.4
    ) | zenity --progress \
        --title="$TITLE" --width=560 --percentage=0 \
        --auto-close --no-cancel 2>/dev/null

    STATUS="${PIPESTATUS[0]}"
else
    if [ "$GUI" = "kdialog" ]; then
        kdialog --title "$TITLE" --passivepopup "Baixando ElegooSlicer $LATEST_VERSION..." 4
    else
        printf '\nBaixando ElegooSlicer %s...\n' "$LATEST_VERSION"
    fi
    perform_install
    STATUS="$?"
fi

if [ "$STATUS" -ne 0 ]; then
    rm -f "$TMP_APPIMAGE"
    if [ -f "$APPIMAGE.bak" ]; then
        rm -f "$APPIMAGE"
        mv "$APPIMAGE.bak" "$APPIMAGE"
    fi
    fail "A instalação não pôde ser concluída.

A versão anterior, se existente, foi preservada.

Código do erro: $STATUS"
fi

gui_info "Tudo ocorreu com sucesso.

<b>ElegooSlicer $LATEST_VERSION</b> foi instalado.

• Versão registrada para futuras verificações
• Atalho principal verifica atualizações silenciosamente
• Se estiver atualizado, o programa abre sem mostrar nenhuma janela
• Atalho Atualizar ElegooSlicer criado
• Atalho Desinstalar ElegooSlicer criado
• Ícone e associações atualizados"

exit 0
