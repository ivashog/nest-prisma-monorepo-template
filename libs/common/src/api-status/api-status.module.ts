import { Module } from '@nestjs/common';

import { ApiStatusService } from './api-status.service';
import { ApiStatusController } from './api-status.controller';

@Module({
    providers: [ApiStatusService],
    controllers: [ApiStatusController],
    exports: [ApiStatusService],
})
export class ApiStatusModule {}
