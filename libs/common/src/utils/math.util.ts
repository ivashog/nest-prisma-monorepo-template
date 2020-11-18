export type NumberFractionDigits =
    | 0
    | 1
    | 2
    | 3
    | 4
    | 5
    | 6
    | 7
    | 8
    | 9
    | 10
    | 11
    | 12
    | 13
    | 14
    | 15;

export const roundTo = (value: number, decimals: NumberFractionDigits = 0): number =>
    Number(+`${Math.round(+`${value}e${decimals}`)}e-${decimals}`);

export const randomBetween = (min: number, max: number): number =>
    Math.floor(Math.random() * (max - min + 1) + min);

export function NOOP() {}
