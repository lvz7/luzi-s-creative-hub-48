import { useState, useEffect } from "react";

function roundDown(n: number, step = 10): string {
  const rounded = Math.floor(n / step) * step;
  return `${rounded}+`;
}

interface DiscordCounts {
  online: string;
  members: string | null;
}

export function useDiscordMemberCount(guildId: string) {
  const [counts, setCounts] = useState<DiscordCounts | null>(null);

  useEffect(() => {
    let cancelled = false;

    // Fetch both widget.json (for online) and the embed endpoint (for total)
    Promise.all([
      fetch(`https://discord.com/api/guilds/${guildId}/widget.json`).then(r => r.json()).catch(() => null),
      fetch(`https://discord.com/api/v9/guilds/${guildId}/widget.json`).then(r => r.json()).catch(() => null),
    ]).then(([widget]) => {
      if (cancelled || !widget) return;
      const online = widget.presence_count ?? widget.members?.length ?? 0;
      setCounts({
        online: roundDown(online),
        members: null, // Discord widget API doesn't expose total member count
      });
    });

    return () => { cancelled = true; };
  }, [guildId]);

  return counts;
}
