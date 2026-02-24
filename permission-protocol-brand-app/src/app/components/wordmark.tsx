interface WordmarkProps {
  size?: "sm" | "md" | "lg" | "xl";
  color?: string;
  mono?: boolean;
  className?: string;
}

const sizeMap = {
  sm: { fontSize: 13, letterSpacing: "0.08em", gap: 6 },
  md: { fontSize: 16, letterSpacing: "0.08em", gap: 7 },
  lg: { fontSize: 22, letterSpacing: "0.07em", gap: 9 },
  xl: { fontSize: 32, letterSpacing: "0.06em", gap: 12 },
};

/**
 * Permission Protocol wordmark.
 *
 * Uses Space Grotesk — geometric, clean, infrastructural.
 * "PERMISSION" is medium weight. "PROTOCOL" is light weight.
 * This creates a visual hierarchy: the subject (permission)
 * is heavier than the system (protocol).
 */
export function Wordmark({
  size = "md",
  color = "currentColor",
  mono = false,
  className = "",
}: WordmarkProps) {
  const s = sizeMap[size];

  return (
    <div
      className={`flex flex-col ${className}`}
      style={{
        color,
        fontFamily: mono ? "'Space Mono', monospace" : "'Space Grotesk', sans-serif",
        letterSpacing: s.letterSpacing,
        lineHeight: 1.1,
        gap: `${s.gap}px`,
      }}
    >
      <span
        style={{
          fontSize: `${s.fontSize}px`,
          fontWeight: 500,
        }}
      >
        PERMISSION
      </span>
      <span
        style={{
          fontSize: `${s.fontSize}px`,
          fontWeight: 300,
          opacity: 0.6,
        }}
      >
        PROTOCOL
      </span>
    </div>
  );
}

interface WordmarkInlineProps {
  size?: "sm" | "md" | "lg";
  color?: string;
  className?: string;
}

const inlineSizeMap = {
  sm: { fontSize: 12, letterSpacing: "0.1em" },
  md: { fontSize: 15, letterSpacing: "0.08em" },
  lg: { fontSize: 20, letterSpacing: "0.07em" },
};

export function WordmarkInline({
  size = "md",
  color = "currentColor",
  className = "",
}: WordmarkInlineProps) {
  const s = inlineSizeMap[size];

  return (
    <span
      className={className}
      style={{
        color,
        fontFamily: "'Space Grotesk', sans-serif",
        fontSize: `${s.fontSize}px`,
        letterSpacing: s.letterSpacing,
        lineHeight: 1,
      }}
    >
      <span style={{ fontWeight: 500 }}>PERMISSION</span>
      <span style={{ fontWeight: 300, opacity: 0.5, margin: "0 0.4em" }}>
        /
      </span>
      <span style={{ fontWeight: 300, opacity: 0.6 }}>PROTOCOL</span>
    </span>
  );
}
