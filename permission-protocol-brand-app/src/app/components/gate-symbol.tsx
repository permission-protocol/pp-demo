import { motion } from "motion/react";

interface GateSymbolProps {
  signed?: boolean;
  size?: number;
  color?: string;
  className?: string;
  animate?: boolean;
}

/**
 * The Gate — primary mark for Permission Protocol.
 *
 * A deny-by-default primitive: a square boundary bisected by a
 * horizontal barrier, with a vertical channel that is severed
 * (blocked) or continuous (signed).
 *
 * When `animate` is true, the channel segments slide together
 * on signing and apart on revocation.
 */
export function GateSymbol({
  signed = false,
  size = 16,
  color = "currentColor",
  className = "",
  animate = false,
}: GateSymbolProps) {
  const strokeWidth = size <= 20 ? 1.5 : size <= 40 ? 1.4 : 1.2;
  const duration = 0.45;
  const ease = [0.4, 0, 0.2, 1] as const;

  if (!animate) {
    return (
      <svg
        width={size}
        height={size}
        viewBox="0 0 16 16"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className={className}
        style={{
          shapeRendering:
            size <= 20 ? "crispEdges" : "geometricPrecision",
        }}
      >
        <rect
          x={1.5}
          y={1.5}
          width={13}
          height={13}
          stroke={color}
          strokeWidth={strokeWidth}
          fill="none"
        />
        <line
          x1={1.5}
          y1={8}
          x2={14.5}
          y2={8}
          stroke={color}
          strokeWidth={strokeWidth}
        />
        {signed ? (
          <line
            x1={8}
            y1={1.5}
            x2={8}
            y2={14.5}
            stroke={color}
            strokeWidth={strokeWidth}
          />
        ) : (
          <>
            <line
              x1={8}
              y1={1.5}
              x2={8}
              y2={5.5}
              stroke={color}
              strokeWidth={strokeWidth}
            />
            <line
              x1={8}
              y1={10.5}
              x2={8}
              y2={14.5}
              stroke={color}
              strokeWidth={strokeWidth}
            />
          </>
        )}
      </svg>
    );
  }

  // Animated version: top segment end and bottom segment start
  // slide toward barrier (y=8) to close the gap when signed.
  //
  // Blocked: top goes 1.5→5.5, bottom goes 10.5→14.5 (gap at barrier)
  // Signed:  top goes 1.5→8,   bottom goes 8→14.5    (continuous)

  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{
        shapeRendering:
          size <= 20 ? "crispEdges" : "geometricPrecision",
      }}
    >
      {/* Boundary */}
      <rect
        x={1.5}
        y={1.5}
        width={13}
        height={13}
        stroke={color}
        strokeWidth={strokeWidth}
        fill="none"
      />

      {/* Barrier */}
      <line
        x1={1.5}
        y1={8}
        x2={14.5}
        y2={8}
        stroke={color}
        strokeWidth={strokeWidth}
      />

      {/* Top channel segment — y2 animates between 5.5 (blocked) and 8 (signed) */}
      <motion.line
        x1={8}
        y1={1.5}
        x2={8}
        animate={{ y2: signed ? 8 : 5.5 }}
        transition={{ duration, ease }}
        stroke={color}
        strokeWidth={strokeWidth}
      />

      {/* Bottom channel segment — y1 animates between 10.5 (blocked) and 8 (signed) */}
      <motion.line
        x1={8}
        x2={8}
        y2={14.5}
        animate={{ y1: signed ? 8 : 10.5 }}
        transition={{ duration, ease }}
        stroke={color}
        strokeWidth={strokeWidth}
      />
    </svg>
  );
}
