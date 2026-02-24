import { GateSymbol } from "./gate-symbol";
import { Wordmark, WordmarkInline } from "./wordmark";

interface LockupProps {
  signed?: boolean;
  color?: string;
  className?: string;
  animate?: boolean;
}

/**
 * Horizontal lockup — mark left, stacked wordmark right.
 */
export function HorizontalLockup({
  signed = false,
  color = "currentColor",
  className = "",
  animate = false,
}: LockupProps) {
  return (
    <div
      className={`flex items-center ${className}`}
      style={{ color, gap: "16px" }}
    >
      <GateSymbol signed={signed} size={40} color={color} animate={animate} />
      <div
        style={{
          width: "1px",
          height: "32px",
          backgroundColor: color,
          opacity: 0.15,
        }}
      />
      <Wordmark size="md" color={color} />
    </div>
  );
}

/**
 * Horizontal lockup compact — mark + inline wordmark.
 */
export function HorizontalLockupCompact({
  signed = false,
  color = "currentColor",
  className = "",
  animate = false,
}: LockupProps) {
  return (
    <div
      className={`flex items-center ${className}`}
      style={{ color, gap: "10px" }}
    >
      <GateSymbol signed={signed} size={20} color={color} animate={animate} />
      <WordmarkInline size="sm" color={color} />
    </div>
  );
}

/**
 * Vertical/stacked lockup — mark on top, wordmark below, centered.
 */
export function VerticalLockup({
  signed = false,
  color = "currentColor",
  className = "",
  animate = false,
}: LockupProps) {
  return (
    <div
      className={`flex flex-col items-center ${className}`}
      style={{ color, gap: "20px" }}
    >
      <GateSymbol signed={signed} size={56} color={color} animate={animate} />
      <Wordmark size="md" color={color} />
    </div>
  );
}