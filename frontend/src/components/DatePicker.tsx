import { useEffect, useRef } from "react";
import flatpickr from "flatpickr";
import "flatpickr/dist/flatpickr.min.css";

interface Props {
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
}

export default function DatePicker({ value, onChange, disabled }: Props) {
  const inputRef = useRef<HTMLInputElement>(null);
  const fpRef = useRef<flatpickr.Instance | null>(null);
  const onChangeRef = useRef(onChange);
  onChangeRef.current = onChange;

  useEffect(() => {
    if (!inputRef.current) return;
    const fp = flatpickr(inputRef.current, {
      dateFormat: "Y-m-d",
      altInput: true,
      altInputClass: "input cursor-pointer disabled:cursor-not-allowed disabled:opacity-50",
      altFormat: "d.m.Y",
      defaultDate: value || undefined,
      disableMobile: true,
      onChange: (_dates, dateStr) => onChangeRef.current(dateStr),
    });
    fpRef.current = fp;
    return () => fp.destroy();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (fpRef.current && value !== fpRef.current.input.value) {
      fpRef.current.setDate(value || "", false);
    }
  }, [value]);

  useEffect(() => {
    fpRef.current?.set("clickOpens", !disabled);
    fpRef.current?.altInput?.toggleAttribute("disabled", Boolean(disabled));
  }, [disabled]);

  return <input ref={inputRef} type="text" placeholder="Tarih seç" readOnly />;
}
