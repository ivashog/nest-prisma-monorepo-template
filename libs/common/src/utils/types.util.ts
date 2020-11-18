export const isUndefined = (obj: any): obj is undefined => typeof obj === 'undefined';
export const isNil = (obj: any): obj is null | undefined => isUndefined(obj) || obj === null;
export const isString = (obj: any): boolean => typeof obj === 'string' || obj instanceof String;
export const isFunction = (fn: any): boolean => typeof fn === 'function';
export const isObject = (fn: any): fn is Record<string, unknown> =>
    !isNil(fn) && typeof fn === 'object';
export const isEmpty = (array: any): boolean => !(array && array.length > 0);
export const isEmptyObject = (obj: any): boolean =>
    Object.keys(obj).length === 0 && obj.constructor === Object;
