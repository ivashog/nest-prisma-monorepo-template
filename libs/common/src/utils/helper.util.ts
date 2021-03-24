import { isString } from '@app/common/utils';

export function NOOP() {}

export const getBuffer = (
    bufferLike: Buffer | string | { type: 'Buffer'; data: number[] },
): Buffer =>
    bufferLike === null
        ? null
        : Buffer.isBuffer(bufferLike)
        ? bufferLike
        : Buffer.from(
              isString(bufferLike)
                  ? bufferLike
                  : (bufferLike as { type: 'Buffer'; data: number[] }).data,
          );
