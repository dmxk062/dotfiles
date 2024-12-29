#!/usr/bin/awk -f
function format(value) {
    if (value >= 1024 * 1024) {
        return sprintf("%.1fG", value / (1024 * 1024))
    } else if (value >= 1024) {
        return sprintf("%.1fM", value / 1024)
    } else {
        return sprintf("%.1fK", value)
    }
}
/MemTotal/{total=$2}
/MemFree/{free=$2}
/MemAvailable/{avail=$2}
END{
    mem_used=total-avail;
    free_nice=format(free);
    total_nice=format(total);
    used_nice=format(mem_used);
    printf "{\"used\": \"%s\", \"free\":\"%s\", \"total\":\"%s\"}", used_nice, free_nice, total_nice
}
