#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

print_success() { echo -e "${GREEN}✔${NC} $1"; }
print_error()   { echo -e "${RED}✖${NC} $1"; }
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_warn()    { echo -e "${YELLOW}⚠${NC} $1"; }

show_header() {
  echo ""
  echo -e "${CYAN}${BOLD}  ╔══════════════════════════════════════╗${NC}"
  echo -e "${CYAN}${BOLD}  ║       Lumicron Portfolio Manager     ║${NC}"
  echo -e "${CYAN}${BOLD}  ╚══════════════════════════════════════╝${NC}"
  echo ""
}

show_help() {
  show_header
  echo -e "${BOLD}Usage:${NC} ./manage.sh ${CYAN}<command>${NC} [options...]"
  echo ""
  echo -e "${BOLD}Album Management:${NC}"
  echo -e "  ${CYAN}new-album${NC}     <name> [--category <cat>]   Create a new album"
  echo -e "  ${CYAN}delete-album${NC}  <slug>                      Delete an album entirely"
  echo -e "  ${CYAN}list-albums${NC}                                List all albums with photo counts"
  echo ""
  echo -e "${BOLD}Photo Management:${NC}"
  echo -e "  ${CYAN}add-photos${NC}    <album-slug> <files...>     Add photo(s) to an album"
  echo -e "  ${CYAN}remove-photo${NC}  <album-slug> <filename>     Remove a photo from an album"
  echo -e "  ${CYAN}list-photos${NC}   <album-slug>                List all photos in an album"
  echo ""
  echo -e "${BOLD}Category Management:${NC}"
  echo -e "  ${CYAN}new-category${NC}  <name>                      Add a new category"
  echo ""
  echo -e "${BOLD}Development:${NC}"
  echo -e "  ${CYAN}dev${NC}                                       Start local dev server"
  echo -e "  ${CYAN}build${NC}                                     Build production static site"
  echo ""
  echo -e "${BOLD}Examples:${NC}"
  echo -e "  ${DIM}./manage.sh new-album \"Grand Canyon\" --category landscapes${NC}"
  echo -e "  ${DIM}./manage.sh add-photos grand-canyon ~/Photos/IMG_001.jpg ~/Photos/IMG_002.jpg${NC}"
  echo -e "  ${DIM}./manage.sh remove-photo grand-canyon IMG_001.jpg${NC}"
  echo -e "  ${DIM}./manage.sh list-albums${NC}"
  echo -e "  ${DIM}./manage.sh delete-album grand-canyon${NC}"
  echo ""
}

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-zA-Z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//'
}

ACTION="$1"
shift || true

case "$ACTION" in

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # CREATE NEW ALBUM
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  new-album)
    NAME="$1"
    shift || true
    if [ -z "$NAME" ]; then
      print_error "Album name is required."
      echo -e "  Usage: ./manage.sh new-album ${CYAN}\"Album Name\"${NC} --category landscapes"
      exit 1
    fi
    
    SLUG=$(slugify "$NAME")
    CATEGORY="all"
    LOCATION="Unknown"
    
    while [[ $# -gt 0 ]]; do
      case $1 in
        --category) CATEGORY="$2"; shift 2 ;;
        --location) LOCATION="$2"; shift 2 ;;
        *) shift ;;
      esac
    done

    ALBUM_DIR="content/albums/$SLUG"
    if [ -d "$ALBUM_DIR" ]; then
      print_error "Album '$SLUG' already exists at $ALBUM_DIR"
      exit 1
    fi

    mkdir -p "$ALBUM_DIR"
    
    cat > "$ALBUM_DIR/_album.json" << EOF
{
  "title": "$NAME",
  "slug": "$SLUG",
  "date": "$(date +%Y-%m-%d)",
  "location": "$LOCATION",
  "categories": ["$CATEGORY"],
  "description": "Album description here.",
  "cover": "",
  "photos": []
}
EOF
    print_success "Created album: ${BOLD}$NAME${NC}"
    echo -e "  ${DIM}Directory: $ALBUM_DIR${NC}"
    echo -e "  ${DIM}Category:  $CATEGORY${NC}"
    echo ""
    print_info "Next: Add photos with ${CYAN}./manage.sh add-photos $SLUG /path/to/photos/*.jpg${NC}"
    ;;

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # DELETE ALBUM
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  delete-album)
    SLUG="$1"
    if [ -z "$SLUG" ]; then
      print_error "Album slug is required."
      exit 1
    fi
    
    ALBUM_DIR="content/albums/$SLUG"
    if [ ! -d "$ALBUM_DIR" ]; then
      print_error "Album '$SLUG' not found."
      exit 1
    fi

    PHOTO_COUNT=$(find "$ALBUM_DIR" -maxdepth 1 -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' | wc -l | tr -d ' ')
    print_warn "This will permanently delete album '${BOLD}$SLUG${NC}' ($PHOTO_COUNT photos)."
    read -p "  Are you sure? (y/N): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
      rm -rf "$ALBUM_DIR"
      print_success "Deleted album: $SLUG"
    else
      print_info "Cancelled."
    fi
    ;;

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # LIST ALL ALBUMS
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  list-albums)
    show_header
    echo -e "${BOLD}  Albums${NC}"
    echo -e "  ${DIM}────────────────────────────────────────────${NC}"
    
    ALBUMS_DIR="content/albums"
    if [ ! -d "$ALBUMS_DIR" ]; then
      print_error "No albums directory found."
      exit 1
    fi

    TOTAL_ALBUMS=0
    for album_dir in "$ALBUMS_DIR"/*/; do
      [ -d "$album_dir" ] || continue
      TOTAL_ALBUMS=$((TOTAL_ALBUMS + 1))
      
      SLUG=$(basename "$album_dir")
      META="$album_dir/_album.json"
      
      if [ -f "$META" ]; then
        TITLE=$(python3 -c "import json; print(json.load(open('$META'))['title'])" 2>/dev/null || echo "$SLUG")
        PHOTO_COUNT=$(find "$album_dir" -maxdepth 1 \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' \) | wc -l | tr -d ' ')
        
        echo -e "  ${CYAN}●${NC} ${BOLD}$TITLE${NC}  ${DIM}($SLUG)${NC}"
        echo -e "    ${DIM}$PHOTO_COUNT photos${NC}"
      fi
    done
    
    echo -e "  ${DIM}────────────────────────────────────────────${NC}"
    echo -e "  ${BOLD}Total:${NC} $TOTAL_ALBUMS albums"
    echo ""
    ;;

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # ADD PHOTOS TO ALBUM
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  add-photos)
    SLUG="$1"
    shift || true
    if [ -z "$SLUG" ]; then
      print_error "Album slug is required."
      exit 1
    fi
    
    ALBUM_DIR="content/albums/$SLUG"
    if [ ! -d "$ALBUM_DIR" ]; then
      print_error "Album '$SLUG' not found."
      echo -e "  ${DIM}Available albums:${NC}"
      for d in content/albums/*/; do echo -e "    ${CYAN}$(basename "$d")${NC}"; done
      exit 1
    fi

    if [ $# -eq 0 ]; then
      print_error "No files specified."
      echo -e "  Usage: ./manage.sh add-photos $SLUG ${CYAN}/path/to/photo.jpg${NC}"
      exit 1
    fi

    META="$ALBUM_DIR/_album.json"
    ADDED=0
    
    for FILE in "$@"; do
      if [ -f "$FILE" ]; then
        FILENAME=$(basename "$FILE")
        cp "$FILE" "$ALBUM_DIR/$FILENAME"
        
        # Update JSON: add photo entry
        python3 -c "
import json, sys
with open('$META', 'r') as f: data = json.load(f)
entry = {'file': '$FILENAME', 'caption': ''}
# avoid duplicates
if not any(p['file'] == '$FILENAME' for p in data['photos']):
    data['photos'].append(entry)
# set cover if empty
if not data.get('cover'): data['cover'] = '$FILENAME'
with open('$META', 'w') as f: json.dump(data, f, indent=2)
"
        print_success "Added: ${BOLD}$FILENAME${NC}"
        ADDED=$((ADDED + 1))
      else
        print_error "File not found: $FILE"
      fi
    done
    
    echo ""
    print_info "$ADDED photo(s) added to ${BOLD}$SLUG${NC}"
    ;;

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # REMOVE PHOTO FROM ALBUM
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  remove-photo)
    SLUG="$1"
    FILENAME="$2"
    
    if [ -z "$SLUG" ] || [ -z "$FILENAME" ]; then
      print_error "Album slug and filename are required."
      echo -e "  Usage: ./manage.sh remove-photo ${CYAN}<album-slug> <filename>${NC}"
      exit 1
    fi

    ALBUM_DIR="content/albums/$SLUG"
    META="$ALBUM_DIR/_album.json"

    if [ ! -d "$ALBUM_DIR" ]; then
      print_error "Album '$SLUG' not found."
      exit 1
    fi

    PHOTO_PATH="$ALBUM_DIR/$FILENAME"
    if [ ! -f "$PHOTO_PATH" ]; then
      print_error "Photo '$FILENAME' not found in album '$SLUG'."
      echo -e "  ${DIM}Use ${CYAN}./manage.sh list-photos $SLUG${NC}${DIM} to see available photos.${NC}"
      exit 1
    fi

    # Remove the file
    rm -f "$PHOTO_PATH"

    # Remove from _album.json
    python3 -c "
import json
with open('$META', 'r') as f: data = json.load(f)
data['photos'] = [p for p in data['photos'] if p['file'] != '$FILENAME']
# Update cover if it was the removed photo
if data.get('cover') == '$FILENAME':
    data['cover'] = data['photos'][0]['file'] if data['photos'] else ''
with open('$META', 'w') as f: json.dump(data, f, indent=2)
"
    print_success "Removed: ${BOLD}$FILENAME${NC} from ${BOLD}$SLUG${NC}"
    ;;

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # LIST PHOTOS IN AN ALBUM
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  list-photos)
    SLUG="$1"
    if [ -z "$SLUG" ]; then
      print_error "Album slug is required."
      exit 1
    fi

    ALBUM_DIR="content/albums/$SLUG"
    META="$ALBUM_DIR/_album.json"

    if [ ! -d "$ALBUM_DIR" ]; then
      print_error "Album '$SLUG' not found."
      exit 1
    fi

    TITLE=$(python3 -c "import json; print(json.load(open('$META'))['title'])" 2>/dev/null || echo "$SLUG")
    
    echo ""
    echo -e "  ${BOLD}$TITLE${NC} ${DIM}($SLUG)${NC}"
    echo -e "  ${DIM}────────────────────────────────────────────${NC}"
    
    python3 -c "
import json
with open('$META', 'r') as f: data = json.load(f)
cover = data.get('cover', '')
for i, p in enumerate(data['photos'], 1):
    marker = ' ★' if p['file'] == cover else ''
    featured = ' [featured]' if p.get('featured') else ''
    caption = ' - ' + p['caption'] if p.get('caption') else ''
    print(f'  {i:3d}. {p[\"file\"]}{marker}{featured}{caption}')
print(f'\n  Total: {len(data[\"photos\"])} photos')
"
    echo ""
    ;;

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # ADD CATEGORY
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  new-category)
    NAME="$1"
    if [ -z "$NAME" ]; then
      print_error "Category name is required."
      exit 1
    fi
    SLUG=$(slugify "$NAME")
    
    python3 -c "
import json
with open('content/categories.json', 'r') as f: data = json.load(f)
if any(c['slug'] == '$SLUG' for c in data):
    print('Category already exists!')
    exit(1)
data.append({'name': '$NAME', 'slug': '$SLUG', 'cover': ''})
with open('content/categories.json', 'w') as f: json.dump(data, f, indent=2)
"
    print_success "Added category: ${BOLD}$NAME${NC} ($SLUG)"
    ;;

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # DEV / BUILD
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  dev)
    show_header
    print_info "Starting dev server..."
    npm run dev
    ;;
    
  build)
    show_header
    print_info "Building optimized static site..."
    npm run build
    print_success "Build complete. Output → ${BOLD}dist/${NC}"
    ;;

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # HELP / DEFAULT
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  help|--help|-h)
    show_help
    ;;
    
  *)
    if [ -z "$ACTION" ]; then
      show_help
    else
      print_error "Unknown command: $ACTION"
      echo ""
      show_help
    fi
    exit 1
    ;;
esac
