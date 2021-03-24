export interface MvtDbData {
    mvt: Buffer | string;
    updatedAt: Date;
}

export type Headers = Record<string, string>;

export interface MvtHeaders extends Headers {
    ETag: string;
    'Last-Modified': string;
    'Content-Type': string;
    'Content-Encoding'?: string;
}

export interface MvtResponse {
    headers: MvtHeaders;
    buffer: Buffer;
}
