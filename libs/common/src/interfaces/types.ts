import { ApiPropertyOptions } from '@nestjs/swagger';

/**
 * buf.toJSON() Returns a JSON representation of buf
 * @see https://nodejs.org/docs/latest-v12.x/api/buffer.html#buffer_buf_tojson
 */
export interface BufferObject {
    type: 'Buffer';
    data: number[];
}

/** Regular string, just to make it more clear what type of string it is  */
export type UUID = string;
export type KEYID = string;
export type Email = string;

/** Provided object must have integer Id and can have any other fields */
export interface WithId {
    id: number;
    [key: string]: any;
}

/** Provided object must have uuid as id and any other fields */
export interface WithUuid {
    id: UUID;
    [key: string]: any;
}

export interface WithKeyId {
    id: KEYID;
    [key: string]: any;
}

/*
 * Generic type for creating const objects for dtos and entities
 * that provides swagger api properties options metadata
 * (such as 'description' and 'example') in separated *-swagger.constant.ts files.
 * It makes our dtos and entities more cleaner!
 */
export type SwaggerDoc<T> = { [P in keyof T]?: ApiPropertyOptions };

/**
 * Generic type for construct mapped type
 * from properties of T with types of P
 */
export type MappedProps<T extends any, P extends any> = {
    [K in keyof T]: keyof P;
};

/**
 * Generic type for construct type similar to Partial
 * but with required property R from type T
 */
export type PartialWithRequired<T extends any, R extends keyof T> = Pick<T, R> &
    Omit<Partial<T>, R>;

/**
 * Generic type to get enum keys as union string.
 * @example type MyEnumKeysAsStrings = EnumType<typeof MyEnum>;
 */
export type EnumKeyType<TEnum> = keyof TEnum;

/**
 * Generic type for a union of all possible property value types
 * @see https://stackoverflow.com/questions/49285864/is-there-a-valueof-similar-to-keyof-in-typescript
 */
export type ValueOf<T> = T[keyof T];

export type Primitive = boolean | number | string | symbol | null | undefined;

/**
 * Get type of array elements
 */
export type ArrayElement<ArrayType extends readonly unknown[]> = ArrayType[number];
/**
 * Get type of object certain property
 */
export type PropType<TObj, TProp extends keyof TObj> = TObj[TProp];
