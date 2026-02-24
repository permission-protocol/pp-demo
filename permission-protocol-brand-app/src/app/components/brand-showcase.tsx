import { useState } from "react";
import { motion } from "motion/react";
import { GateSymbol } from "./gate-symbol";
import { Wordmark, WordmarkInline } from "./wordmark";
import {
  HorizontalLockup,
  HorizontalLockupCompact,
  VerticalLockup,
} from "./lockups";

function SectionLabel({ children }: { children: string }) {
  return (
    <div
      className="font-mono uppercase tracking-[0.2em] text-[#555] mb-6"
      style={{ fontSize: "10px" }}
    >
      {children}
    </div>
  );
}

function SubLabel({ children }: { children: string }) {
  return (
    <div
      className="font-mono text-[#444] mt-4 mb-1"
      style={{ fontSize: "9px", letterSpacing: "0.15em" }}
    >
      {children}
    </div>
  );
}

function Divider() {
  return <div className="w-full h-px bg-[#1a1a1a] my-16" />;
}

function ShowcaseCard({
  bg,
  children,
  className = "",
}: {
  bg: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={`flex items-center justify-center p-10 ${className}`}
      style={{ backgroundColor: bg, minHeight: "160px" }}
    >
      {children}
    </div>
  );
}

export function BrandShowcase() {
  const [signed, setSigned] = useState(false);

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-[#d0d0d0]">
      {/* ========== TOP BAR ========== */}
      <div className="sticky top-0 z-50 bg-[#0a0a0a]/90 backdrop-blur-md border-b border-[#161616]">
        <div className="max-w-[1100px] mx-auto px-8 py-4 flex items-center justify-between">
          <HorizontalLockupCompact signed={signed} color="#999" animate />
          <button
            onClick={() => setSigned(!signed)}
            className="font-mono px-4 py-1.5 border cursor-pointer transition-all duration-300"
            style={{
              fontSize: "11px",
              borderColor: signed ? "#4a9" : "#333",
              color: signed ? "#4a9" : "#666",
              background: signed
                ? "rgba(68, 170, 153, 0.05)"
                : "transparent",
            }}
          >
            {signed ? "● signed" : "○ unsigned"}
          </button>
        </div>
      </div>

      <div className="max-w-[1100px] mx-auto px-8 py-20">
        {/* ========== HERO ========== */}
        <div className="flex flex-col items-center text-center mb-8">
          <div
            className="font-mono text-[#333] uppercase tracking-[0.3em] mb-10"
            style={{ fontSize: "9px" }}
          >
            Brand Identity System
          </div>
          <motion.div
            animate={{ color: signed ? "#d0d0d0" : "#777" }}
            transition={{ duration: 0.5 }}
          >
            <GateSymbol signed={signed} size={80} animate />
          </motion.div>
          <motion.div
            className="mt-8"
            animate={{ opacity: signed ? 1 : 0.65 }}
            transition={{ duration: 0.5 }}
          >
            <Wordmark
              size="xl"
              color={signed ? "#d0d0d0" : "#777"}
            />
          </motion.div>
          <p
            className="font-mono text-[#444] mt-8 max-w-md"
            style={{ fontSize: "12px", lineHeight: 1.7 }}
          >
            Deny by default. Permit by proof.
            <br />
            The gate is always closed.
          </p>
        </div>

        <Divider />

        {/* ========== 01. PRIMARY MARK ========== */}
        <SectionLabel>01 — Primary Mark</SectionLabel>

        <div className="grid grid-cols-2 gap-6 mb-6">
          <ShowcaseCard bg="#0e0e0e">
            <div className="flex items-end gap-8">
              {[16, 24, 32, 48, 64].map((s) => (
                <div key={s} className="flex flex-col items-center gap-3">
                  <GateSymbol
                    signed={signed}
                    size={s}
                    color={signed ? "#c8c8c8" : "#888"}
                    animate
                  />
                  <span
                    className="font-mono text-[#333]"
                    style={{ fontSize: "9px" }}
                  >
                    {s}
                  </span>
                </div>
              ))}
            </div>
          </ShowcaseCard>
          <ShowcaseCard bg="#f0f0ed">
            <div className="flex items-end gap-8">
              {[16, 24, 32, 48, 64].map((s) => (
                <div key={s} className="flex flex-col items-center gap-3">
                  <GateSymbol
                    signed={signed}
                    size={s}
                    color={signed ? "#1a1a1a" : "#555"}
                    animate
                  />
                  <span
                    className="font-mono text-[#bbb]"
                    style={{ fontSize: "9px" }}
                  >
                    {s}
                  </span>
                </div>
              ))}
            </div>
          </ShowcaseCard>
        </div>

        <div
          className="font-mono text-[#444] mt-3"
          style={{ fontSize: "11px", lineHeight: 1.7 }}
        >
          The mark exists in two states.{" "}
          <span className="text-[#666]">Blocked</span> is the resting state —
          the channel is severed at the barrier.{" "}
          <span className="text-[#666]">Signed</span> is the authorized state —
          the channel crosses through. The mark always defaults to blocked.
        </div>

        <Divider />

        {/* ========== 02. INTERACTIVE ANIMATION ========== */}
        <SectionLabel>02 — Interactive Animation</SectionLabel>

        <div className="flex flex-col items-center py-8">
          <div
            className="font-mono text-[#666] tracking-widest uppercase mb-3"
            style={{ fontSize: "11px" }}
          >
            primitive
          </div>
          <h2
            className="font-mono text-[#c8c8c8] tracking-tight mb-3"
            style={{
              fontSize: "20px",
              fontWeight: 400,
              fontFamily: "'Space Mono', monospace",
            }}
          >
            gate
          </h2>
          <p
            className="font-mono text-[#555] mb-10"
            style={{ fontSize: "12px" }}
          >
            no action without explicit authorization
          </p>

          {/* Toggle */}
          <button
            onClick={() => setSigned(!signed)}
            className="mb-12 font-mono px-5 py-2 border transition-all duration-300 cursor-pointer"
            style={{
              fontSize: "12px",
              borderColor: signed ? "#4a9" : "#555",
              color: signed ? "#4a9" : "#888",
              background: signed
                ? "rgba(68, 170, 153, 0.06)"
                : "transparent",
            }}
          >
            <span className="mr-2">{signed ? "●" : "○"}</span>
            {signed ? "signed" : "unsigned"}
          </button>

          {/* Animated size ladder */}
          <div className="flex items-end gap-10 mb-12">
            {[16, 24, 32, 48, 64, 128].map((size) => (
              <div key={size} className="flex flex-col items-center gap-3">
                <motion.div
                  className="flex items-center justify-center"
                  animate={{ color: signed ? "#c8c8c8" : "#888" }}
                  transition={{ duration: 0.5 }}
                >
                  <GateSymbol signed={signed} size={size} animate />
                </motion.div>
                <span
                  className="font-mono text-[#444]"
                  style={{ fontSize: "10px" }}
                >
                  {size}px
                </span>
              </div>
            ))}
          </div>

          {/* State readout */}
          <div
            className="font-mono p-4 border border-[#1a1a1a] bg-[#060606] w-full max-w-sm"
            style={{ fontSize: "12px", fontFamily: "'Space Mono', monospace" }}
          >
            <div className="flex items-center gap-3 mb-1">
              <motion.span
                animate={{ color: signed ? "#44aa99" : "#555" }}
                transition={{ duration: 0.3 }}
              >
                state
              </motion.span>
              <span className="text-[#333]">→</span>
              <motion.span
                animate={{ color: signed ? "#c8c8c8" : "#666" }}
                transition={{ duration: 0.3 }}
              >
                {signed ? "signed" : "unsigned"}
              </motion.span>
            </div>
            <div className="flex items-center gap-3 mb-1">
              <span className="text-[#444]">channel</span>
              <span className="text-[#333]">→</span>
              <motion.span
                animate={{ color: signed ? "#c8c8c8" : "#666" }}
                transition={{ duration: 0.3 }}
              >
                {signed ? "continuous" : "severed"}
              </motion.span>
            </div>
            <div className="flex items-center gap-3">
              <span className="text-[#444]">crossing</span>
              <span className="text-[#333]">→</span>
              <motion.span
                animate={{ color: signed ? "#44aa99" : "#aa4455" }}
                transition={{ duration: 0.3 }}
              >
                {signed ? "permitted" : "denied"}
              </motion.span>
            </div>
          </div>
        </div>

        <div
          className="font-mono text-[#444] mt-4"
          style={{ fontSize: "11px", lineHeight: 1.7 }}
        >
          The channel segments animate toward the barrier when signing and
          retract when revoking. The transition is{" "}
          <span className="text-[#666]">450ms ease-out</span> — deliberate
          enough to feel like a mechanical action, not a toggle. The animation
          is optional and should only appear in interactive contexts.
        </div>

        <Divider />

        {/* ========== 03. WORDMARK ========== */}
        <SectionLabel>03 — Wordmark</SectionLabel>

        <div className="grid grid-cols-2 gap-6 mb-6">
          <ShowcaseCard bg="#0e0e0e">
            <Wordmark size="lg" color="#c8c8c8" />
          </ShowcaseCard>
          <ShowcaseCard bg="#f0f0ed">
            <Wordmark size="lg" color="#1a1a1a" />
          </ShowcaseCard>
        </div>

        <SubLabel>INLINE VARIANT</SubLabel>
        <div className="grid grid-cols-2 gap-6 mb-4">
          <ShowcaseCard bg="#0e0e0e" className="!min-h-[80px]">
            <WordmarkInline size="lg" color="#c8c8c8" />
          </ShowcaseCard>
          <ShowcaseCard bg="#f0f0ed" className="!min-h-[80px]">
            <WordmarkInline size="lg" color="#1a1a1a" />
          </ShowcaseCard>
        </div>

        <div
          className="font-mono text-[#444] mt-3"
          style={{ fontSize: "11px", lineHeight: 1.7 }}
        >
          <span className="text-[#666]">PERMISSION</span> is set in Space
          Grotesk Medium.{" "}
          <span className="text-[#666]">PROTOCOL</span> is set in Space
          Grotesk Light at 60% opacity. The weight differential creates a
          subject–system hierarchy. The inline variant uses a slash separator
          for compact contexts.
        </div>

        <Divider />

        {/* ========== 04. LOCKUPS ========== */}
        <SectionLabel>04 — Lockups</SectionLabel>

        <SubLabel>HORIZONTAL</SubLabel>
        <div className="grid grid-cols-2 gap-6 mb-6">
          <ShowcaseCard bg="#0e0e0e">
            <HorizontalLockup signed={signed} color="#c8c8c8" animate />
          </ShowcaseCard>
          <ShowcaseCard bg="#f0f0ed">
            <HorizontalLockup signed={signed} color="#1a1a1a" animate />
          </ShowcaseCard>
        </div>

        <SubLabel>HORIZONTAL COMPACT</SubLabel>
        <div className="grid grid-cols-2 gap-6 mb-6">
          <ShowcaseCard bg="#0e0e0e" className="!min-h-[80px]">
            <HorizontalLockupCompact signed={signed} color="#c8c8c8" animate />
          </ShowcaseCard>
          <ShowcaseCard bg="#f0f0ed" className="!min-h-[80px]">
            <HorizontalLockupCompact signed={signed} color="#1a1a1a" animate />
          </ShowcaseCard>
        </div>

        <SubLabel>VERTICAL / STACKED</SubLabel>
        <div className="grid grid-cols-2 gap-6">
          <ShowcaseCard bg="#0e0e0e" className="!min-h-[240px]">
            <VerticalLockup signed={signed} color="#c8c8c8" animate />
          </ShowcaseCard>
          <ShowcaseCard bg="#f0f0ed" className="!min-h-[240px]">
            <VerticalLockup signed={signed} color="#1a1a1a" animate />
          </ShowcaseCard>
        </div>

        <Divider />

        {/* ========== 05. COLOR SYSTEM ========== */}
        <SectionLabel>05 — Color System</SectionLabel>

        <div className="grid grid-cols-5 gap-4 mb-6">
          {[
            {
              name: "Void",
              hex: "#0a0a0a",
              desc: "Primary background",
            },
            {
              name: "Ash",
              hex: "#1a1a1a",
              desc: "Surface / borders",
            },
            {
              name: "Signal",
              hex: "#c8c8c8",
              desc: "Primary foreground",
            },
            {
              name: "Permit",
              hex: "#44aa99",
              desc: "Authorized state",
            },
            {
              name: "Deny",
              hex: "#aa4455",
              desc: "Blocked / error",
            },
          ].map((c) => (
            <div key={c.hex}>
              <div
                className="aspect-square border border-[#222] mb-3"
                style={{ backgroundColor: c.hex }}
              />
              <div className="font-mono" style={{ fontSize: "11px" }}>
                <div className="text-[#888]">{c.name}</div>
                <div className="text-[#555]">{c.hex}</div>
                <div
                  className="text-[#3a3a3a] mt-1"
                  style={{ fontSize: "9px" }}
                >
                  {c.desc}
                </div>
              </div>
            </div>
          ))}
        </div>

        <div
          className="font-mono text-[#444] mt-3"
          style={{ fontSize: "11px", lineHeight: 1.7 }}
        >
          The palette is near-monochrome by default. Color enters the system
          only through state:{" "}
          <span style={{ color: "#44aa99" }}>Permit</span> for authorized
          actions, <span style={{ color: "#aa4455" }}>Deny</span> for blocked
          states. The brand lives in the absence of color.
        </div>

        <Divider />

        {/* ========== 06. ON BACKGROUNDS ========== */}
        <SectionLabel>06 — Contextual Application</SectionLabel>

        <div className="grid grid-cols-3 gap-4 mb-4">
          <ShowcaseCard bg="#0a0a0a" className="border border-[#1a1a1a]">
            <VerticalLockup signed={signed} color="#c8c8c8" animate />
          </ShowcaseCard>
          <ShowcaseCard bg="#ffffff">
            <VerticalLockup signed={signed} color="#0a0a0a" animate />
          </ShowcaseCard>
          <ShowcaseCard bg="#44aa99">
            <VerticalLockup signed={true} color="#0a0a0a" />
          </ShowcaseCard>
        </div>

        <div className="grid grid-cols-3 gap-4">
          {[
            { bg: "#111", color: "#44aa99", label: "Terminal / CLI" },
            { bg: "#1a1a2e", color: "#c8c8c8", label: "Product UI" },
            { bg: "#f5f5f0", color: "#1a1a1a", label: "Documentation" },
          ].map((ctx) => (
            <div key={ctx.label}>
              <ShowcaseCard bg={ctx.bg} className="!min-h-[100px]">
                <HorizontalLockupCompact signed={signed} color={ctx.color} animate />
              </ShowcaseCard>
              <div
                className="font-mono text-[#444] mt-2 text-center"
                style={{ fontSize: "9px", letterSpacing: "0.1em" }}
              >
                {ctx.label}
              </div>
            </div>
          ))}
        </div>

        <Divider />

        {/* ========== 07. CLEAR SPACE & MINIMUM SIZE ========== */}
        <SectionLabel>07 — Clear Space & Minimum Size</SectionLabel>

        <div className="flex items-start gap-16 mb-6">
          <div>
            <SubLabel>CLEAR SPACE</SubLabel>
            <div className="inline-block relative mt-2">
              <div
                className="border border-dashed border-[#333] p-6"
                style={{ padding: "24px" }}
              >
                <GateSymbol signed={signed} size={48} color="#888" animate />
              </div>
              <div
                className="absolute -top-4 left-1/2 -translate-x-1/2 font-mono text-[#44aa99]"
                style={{ fontSize: "9px" }}
              >
                1×
              </div>
              <div
                className="absolute top-1/2 -left-4 -translate-y-1/2 font-mono text-[#44aa99]"
                style={{ fontSize: "9px" }}
              >
                1×
              </div>
            </div>
            <div
              className="font-mono text-[#444] mt-3"
              style={{ fontSize: "10px" }}
            >
              Minimum clear space = 1× mark width
            </div>
          </div>

          <div>
            <SubLabel>MINIMUM SIZE</SubLabel>
            <div className="flex items-end gap-6 mt-2">
              <div className="flex flex-col items-center gap-2">
                <div className="border border-dashed border-[#333] p-2">
                  <GateSymbol signed={signed} size={16} color="#888" animate />
                </div>
                <span
                  className="font-mono text-[#44aa99]"
                  style={{ fontSize: "9px" }}
                >
                  16px ✓
                </span>
              </div>
              <div className="flex flex-col items-center gap-2">
                <div className="border border-dashed border-[#333] p-2 opacity-40">
                  <GateSymbol signed={signed} size={12} color="#888" />
                </div>
                <span
                  className="font-mono text-[#aa4455]"
                  style={{ fontSize: "9px" }}
                >
                  12px ✗
                </span>
              </div>
            </div>
            <div
              className="font-mono text-[#444] mt-3"
              style={{ fontSize: "10px" }}
            >
              Do not render below 16px
            </div>
          </div>
        </div>

        <Divider />

        {/* ========== 08. APP ICON / FAVICON ========== */}
        <SectionLabel>08 — App Icon & Favicon</SectionLabel>

        <div className="flex items-end gap-8 mb-6">
          {[
            { size: 128, radius: 28, padding: 28 },
            { size: 64, radius: 14, padding: 14 },
            { size: 32, radius: 7, padding: 6 },
            { size: 16, radius: 3, padding: 2 },
          ].map((icon) => (
            <div
              key={icon.size}
              className="flex flex-col items-center gap-3"
            >
              <div
                className="flex items-center justify-center"
                style={{
                  width: icon.size,
                  height: icon.size,
                  borderRadius: icon.radius,
                  backgroundColor: "#111",
                  border: "1px solid #222",
                  padding: icon.padding,
                }}
              >
                <GateSymbol
                  signed={signed}
                  size={icon.size - icon.padding * 2}
                  color="#c8c8c8"
                  animate
                />
              </div>
              <span
                className="font-mono text-[#444]"
                style={{ fontSize: "9px" }}
              >
                {icon.size}
              </span>
            </div>
          ))}
        </div>

        <Divider />

        {/* ========== 09. TYPOGRAPHY ========== */}
        <SectionLabel>09 — Typography</SectionLabel>

        <div className="grid grid-cols-2 gap-12 mb-6">
          <div>
            <SubLabel>PRIMARY — SPACE GROTESK</SubLabel>
            <div
              className="text-[#c8c8c8] mt-3"
              style={{
                fontFamily: "'Space Grotesk', sans-serif",
                fontSize: "28px",
                fontWeight: 300,
                lineHeight: 1.3,
              }}
            >
              Deny by default.
              <br />
              <span style={{ fontWeight: 500 }}>Permit by proof.</span>
            </div>
            <div
              className="font-mono text-[#333] mt-4"
              style={{ fontSize: "9px", letterSpacing: "0.1em" }}
            >
              LIGHT 300 · MEDIUM 500
            </div>
          </div>
          <div>
            <SubLabel>SYSTEM / CODE — SPACE MONO</SubLabel>
            <div
              className="text-[#888] mt-3"
              style={{
                fontFamily: "'Space Mono', monospace",
                fontSize: "14px",
                lineHeight: 1.6,
              }}
            >
              <span style={{ color: "#44aa99" }}>gate</span>
              {" --state=unsigned"}
              <br />
              {"  "}
              <span style={{ color: "#555" }}>→ channel: severed</span>
              <br />
              {"  "}
              <span style={{ color: "#555" }}>→ crossing: denied</span>
              <br />
              <br />
              <span style={{ color: "#44aa99" }}>gate</span>
              {" --sign=proof.sig"}
              <br />
              {"  "}
              <span style={{ color: "#888" }}>→ channel: continuous</span>
              <br />
              {"  "}
              <span style={{ color: "#888" }}>→ crossing: permitted</span>
            </div>
            <div
              className="font-mono text-[#333] mt-4"
              style={{ fontSize: "9px", letterSpacing: "0.1em" }}
            >
              REGULAR 400
            </div>
          </div>
        </div>

        <Divider />

        {/* ========== 10. MISUSE ========== */}
        <SectionLabel>10 — Incorrect Usage</SectionLabel>

        <div className="grid grid-cols-4 gap-6 mb-6">
          {[
            { label: "Do not rotate", transform: "rotate(45deg)" },
            { label: "Do not stretch", transform: "scaleX(1.5)" },
            {
              label: "Do not outline only partially",
              style: { opacity: 0.3 },
            },
            {
              label: "Do not add effects",
              style: {
                filter: "blur(1px) drop-shadow(0 0 8px #44aa99)",
              },
            },
          ].map((misuse) => (
            <div
              key={misuse.label}
              className="flex flex-col items-center"
            >
              <div
                className="flex items-center justify-center p-6 border border-dashed border-[#aa4455]/30 mb-3"
                style={{ minHeight: "100px" }}
              >
                <div
                  style={{
                    transform: misuse.transform,
                    ...misuse.style,
                  }}
                >
                  <GateSymbol signed={signed} size={40} color="#555" />
                </div>
              </div>
              <div className="flex items-center gap-1">
                <span style={{ color: "#aa4455", fontSize: "10px" }}>
                  ✗
                </span>
                <span
                  className="font-mono text-[#555]"
                  style={{ fontSize: "9px" }}
                >
                  {misuse.label}
                </span>
              </div>
            </div>
          ))}
        </div>

        {/* ========== FOOTER ========== */}
        <div className="mt-20 pt-8 border-t border-[#141414]">
          <div className="flex items-center justify-between">
            <HorizontalLockupCompact signed={signed} color="#333" animate />
            <div
              className="font-mono text-[#2a2a2a]"
              style={{ fontSize: "9px" }}
            >
              Brand Identity Guidelines v1.0
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
