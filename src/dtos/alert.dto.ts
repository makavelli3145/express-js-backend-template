import { IsNotEmpty, IsNumber, IsString, Matches } from 'class-validator';

export class CreateAlertDto {
  @IsString()
  @IsNotEmpty()
  public device_uuid: string;
  @IsString()
  @IsNotEmpty()
  @Matches(/^-?\d+(\.\d+)?\|-?\d+(\.\d+)?$/, {
    message: 'location must be in the format <longitude>|<latitude>',
  })
  public location: string;
}

export class UpdateAlertDto extends CreateAlertDto {
  @IsNumber()
  @IsNotEmpty()
  public id: number;
  @IsNumber()
  @IsNotEmpty()
  public push_notification_id: number;
}

export class DeleteAlertDto extends UpdateAlertDto {}
