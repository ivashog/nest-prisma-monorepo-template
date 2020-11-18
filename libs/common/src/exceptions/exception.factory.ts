import { HttpException, HttpStatus, ValidationError } from '@nestjs/common';

export function formatErrors(errors: any[]): string[] {
    function formatter(err) {
        return err.map(e => {
            if (e.constraints) {
                for (const property in e.constraints) {
                    if (e.constraints.hasOwnProperty(property)) {
                        return e.constraints[property];
                    }
                }
            } else {
                return formatErrors(e.children);
            }
        });
    }

    const errorSet = new Set([]);
    formatter(errors).forEach(err => errorSet.add(err));

    return Array.from(Array.from(errorSet));
}

export const exceptionFactory = (errors: ValidationError[]) => {
    return new HttpException(formatErrors(errors), HttpStatus.BAD_REQUEST);
};
