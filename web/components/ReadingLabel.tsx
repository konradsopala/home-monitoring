import { useRef, useMemo } from "react";

interface ReadingLabelProps {
  value: number | null;
  unit: string;
}

export function ReadingLabel({ value, unit }: ReadingLabelProps) {
  const formatValue = (v: any): any => {
    return v !== null ? `${v} ${unit}` : `-- ${unit}`;
  };

  const display: any = formatValue(value);

  return <p className="text-white text-5xl font-black">{display}</p>;
}
