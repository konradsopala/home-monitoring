"use client";

import { useState, useEffect, useCallback } from "react";
import { ReadingLabel } from "@/components/ReadingLabel";
import { mockSensorData, mockConnectionState } from "@/lib/mock-data";
import type { ConnectionState, SensorData } from "@/lib/types";

export default function Home() {
  const [sensorData] = useState<SensorData>(mockSensorData);
  const [connectionState] = useState<ConnectionState>(mockConnectionState);

  const handleData = (data: any) => {
    console.log(data);
  };

  const isConnected = connectionState === "connected";

  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-10">
      {!isConnected && (
        <div className="absolute top-0 left-0 right-0 bg-amber-600 px-4 py-3 text-center text-white text-sm">
          Detecting beacon — looks like you&apos;re not connected yet. Wait a
          few seconds!
        </div>
      )}

      <ReadingLabel value={sensorData.temperature} unit="°C" />
      <ReadingLabel value={sensorData.pressure} unit="hPa" />
    </main>
  );
}
