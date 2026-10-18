#!/usr/bin/env bash

names=("" line square cube tesseract penteract hexeract hepteract octeract enneract dekeract)

[[ -t 0 && -t 1 ]] || { echo "dimensions: run this in a terminal" >&2; exit 1; }
command -v awk >/dev/null || { echo "dimensions: awk is missing" >&2; exit 1; }

uni=0
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *[Uu][Tt][Ff]-8* | *[Uu][Tt][Ff]8*) uni=1 ;;
esac
[[ $TERM == linux ]] && uni=0

shopt -s checkwinsize
read -r LINES COLUMNS < <(stty size 2>/dev/null)
: "${LINES:=24}" "${COLUMNS:=80}"

IFS= read -r -d '' prog <<'EOF'
function abs(v) { return v < 0 ? -v : v }

function plot(px, py, z,    c, key) {
    if (px < 0 || px >= W || py < 0 || py >= H) return
    c = int(py / ry) * cols + int(px / rx)
    if (uni) {
        key = py * W + px
        if (!(key in on)) {
            on[key] = 1
            mask[c] += wt[(px % 2) * 4 + py % 4]
        }
    }
    if (!(c in dep) || z > dep[c]) dep[c] = z
}

function edge(p, q,    x0, y0, z0, dx, dy, zd, steps, s, t) {
    x0 = sx[p]; y0 = sy[p]; z0 = dz[p]
    dx = sx[q] - x0; dy = sy[q] - y0; zd = dz[q] - z0
    steps = int(abs(dx) > abs(dy) ? abs(dx) : abs(dy)) + 1
    if (steps > 3 * (W + H)) return
    for (s = 0; s <= steps; s++) {
        t = s / steps
        plot(int(x0 + dx * t + 0.5), int(y0 + dy * t + 0.5), z0 + zd * t)
    }
}

BEGIN {
    if (cols < 10 || rows < 4) exit

    n = d < 3 ? 3 : d
    th = ph / 1000
    rx = uni ? 2 : 1
    ry = uni ? 4 : 1
    W = cols * rx
    H = rows * ry
    P = (cols / 2 < rows ? cols / 2 : rows) / 1.5
    kx = P * rx
    ky = P * ry / 2

    split("1 2 4 64 8 16 32 128", wt, " ")
    for (i = 1; i <= 8; i++) wt[i - 1] = wt[i]
    ramp = ".:-=+*#%@"
    if (uni) for (m = 1; m < 256; m++)
        glyph[m] = sprintf("%c%c%c", 226, 160 + int(m / 64), 128 + m % 64)

    np = 0
    for (i = 0; i < n; i++) {
        pa[np] = i
        pb[np] = (i + 1) % n
        np++
    }
    if (n >= 4) for (i = 0; i < n; i++) {
        pa[np] = i
        pb[np] = (i + 2) % n
        np++
    }
    for (k = 0; k < np; k++) {
        a = th * (0.4 + 0.13 * ((k * 3) % 11))
        cs[k] = cos(a)
        sn[k] = sin(a)
    }

    nv = 2 ^ d
    norm = 1 / sqrt(d)
    for (i = 0; i < d; i++) bitv[i] = 2 ^ i

    zmin = 1e9
    zmax = -1e9
    for (v = 0; v < nv; v++) {
        for (i = 0; i < n; i++)
            x[i] = (i < d) ? ((int(v / bitv[i]) % 2) ? norm : -norm) : 0
        for (k = 0; k < np; k++) {
            a = x[pa[k]]
            b = x[pb[k]]
            x[pa[k]] = a * cs[k] - b * sn[k]
            x[pb[k]] = a * sn[k] + b * cs[k]
        }
        for (k = n - 1; k >= 2; k--) {
            den = 1 - x[k] * 0.4
            if (den < 0.3) den = 0.3
            f = 1 / den
            if (k == 2) z = x[2]
            for (i = 0; i < k; i++) x[i] *= f
        }
        sx[v] = W / 2 + x[0] * kx
        sy[v] = H / 2 - x[1] * ky
        dz[v] = z
        if (z < zmin) zmin = z
        if (z > zmax) zmax = z
    }
    for (v = 0; v < nv; v++) dz[v] = (dz[v] - zmin) / (zmax - zmin + 1e-9)

    for (v = 0; v < nv; v++)
        for (i = 0; i < d; i++)
            if (int(v / bitv[i]) % 2 == 0) edge(v, v + bitv[i])

    out = "\033[?2026h\033[H"
    for (r = 0; r < rows; r++) {
        row = "\033[97m"
        for (col = 0; col < cols; col++) {
            c = r * cols + col
            if (!(c in dep)) { row = row " "; continue }
            row = row (uni ? glyph[mask[c]] : substr(ramp, int(dep[c] * 8) + 1, 1))
        }
        out = out row "\033[0m\n"
    }
    out = out "\033[2K\033[2m" substr(hud, 1, cols - 1) "\033[0m\033[?2026l"
    printf "%s", out
}
EOF

menu() {
    local i word
    printf '\n  \033[1mdimensions\033[0m\n\n'
    for i in {1..10}; do
        word=dimensions
        (( i == 1 )) && word=dimension
        printf '  %2d) %2d %-11s (%s)\n' "$i" "$i" "$word" "${names[i]}"
    done
    printf '\n  pick 1-10, q quits: '
}

play() {
    local d=$1 ph=0 sp=6 paused=0 key hud last= tick now prev=${EPOCHREALTIME/[.,]/}
    printf '\033[2J\033[?25l'
    while :; do
        tick=0.01
        (( paused )) && tick=0.1
        read -rsn1 -t $tick key
        case $key in
            q) break ;;
            p | ' ') paused=$(( 1 - paused )) ;;
            + | =) (( sp < 30 )) && (( sp++ )) ;;
            - | _) (( sp > 1 )) && (( sp-- )) ;;
            [1-9]) d=$key ;;
            0) d=10 ;;
        esac
        now=${EPOCHREALTIME/[.,]/}
        (( paused )) || ph=$(( ph + (now - prev > 200000 ? 200000 : now - prev) * sp * 4 / 10000 ))
        prev=$now
        hud=" ${d}D ${names[d]}  speed $sp  1-9,0 dimension  p pause  +/- speed  q menu"
        (( paused )) && hud+="  [paused]"
        if [[ $LINES.$COLUMNS != "$last" ]]; then
            printf '\033[2J'
            last=$LINES.$COLUMNS
        fi
        LC_ALL=C awk -v d="$d" -v ph="$ph" -v cols="$COLUMNS" -v rows="$(( LINES - 1 ))" \
            -v uni="$uni" -v hud="$hud" "$prog"
    done
}

trap 'printf "\033[0m\033[?25h\033[?1049l"; stty echo 2>/dev/null' EXIT
trap 'exit 130' INT TERM

printf '\033[?1049h'
while :; do
    printf '\033[2J\033[H\033[?25h'
    menu
    read -r choice || break
    case $choice in
        q | Q) break ;;
        [1-9] | 10) play "$choice" ;;
    esac
done
