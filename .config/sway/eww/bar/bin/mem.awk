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
/SwapTotal/{swap_total=$2}
/SwapFree/{swap_free=$2}
END{
    mem_used=total-avail;
    mem_perc=(mem_used/total)*100;
    swap_used=swap_total-swap_free;
    swap_perc=(swap_used/swap_total)*100;
    free_nice=format(free);
    total_nice=format(total);
    avail_nice=format(avail);
    used_nice=format(mem_used);
    swap_total_nice=format(swap_total);
    swap_used_nice=format(swap_used);
    swap_free_nice=format(swap_free)
    printf "{\"mem\":{\"raw\":{\"total\":%s,\"free\":%s,\"avail\":%s,\"used\":%s,\"perc\":%s},\"nice\":{\"total\":\"%s\",\"free\":\"%s\",\"avail\":\"%s\",\"used\":\"%s\"}},\"swap\":{\"raw\":{\"total\":%s,\"free\":%s,\"used\":%s,\"perc\":%s},\"nice\":{\"total\":\"%s\",\"free\":\"%s\",\"used\":\"%s\"}}}\n",total,free,avail,mem_used,mem_perc,total_nice,free_nice,avail_nice,used_nice,swap_total,swap_free,swap_used,swap_perc,swap_total_nice,swap_free_nice,swap_used_nice
    }
