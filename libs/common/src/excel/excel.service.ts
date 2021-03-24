import { Injectable } from '@nestjs/common';
import * as Excel from 'exceljs';
import { Readable } from 'stream';

export interface ExcelOptions {
    headers: Partial<Excel.Column>[];
    rows: any[];
    sheetname?: string;
}

@Injectable()
export class ExcelService {
    public generateExcel({ headers, rows, sheetname = 'Worksheet' }: ExcelOptions): Excel.Workbook {
        const workbook = new Excel.Workbook();
        const sheet = workbook.addWorksheet(sheetname, { pageSetup: { scale: 80 } });

        sheet.columns = headers as any[];
        rows.forEach(row => sheet.addRow(row));
        sheet.getRow(1).height = 50;
        sheet.getRow(1).alignment = { horizontal: 'left', vertical: 'middle', wrapText: true };
        sheet.getRow(1).font = { bold: true, size: 10 };

        return workbook;
    }

    public async generateCsv(headers: Partial<Excel.Column>[], csvRows: any[]) {
        const workbook = new Excel.Workbook();
        const sheet = workbook.addWorksheet();

        sheet.columns = headers as any[];
        csvRows.forEach(row => sheet.addRow(row));

        return await workbook.csv.writeBuffer();
    }

    public async generateXlsxBuffer(
        headers: Partial<Excel.Column>[],
        rows: any[],
        sheetname = 'Worksheet',
    ): Promise<Buffer> {
        const workbook = new Excel.stream.xlsx.WorkbookWriter({});
        const sheet: Excel.Worksheet = workbook.addWorksheet(sheetname);

        sheet.columns = headers as any[];
        rows.forEach(row => sheet.addRow(row));
        sheet.commit();

        return new Promise((resolve, reject): void => {
            workbook
                .commit()
                .then(() => {
                    const stream: Readable = (workbook as any).stream;
                    const result: Buffer = stream.read();
                    resolve(result);
                })
                .catch(e => {
                    reject(e);
                });
        });
    }
}
