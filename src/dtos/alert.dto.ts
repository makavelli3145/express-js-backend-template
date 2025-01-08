import { IsNotEmpty, IsNumber, IsString, Matches } from 'class-validator';

export class CreateAlertDto {
  @IsString()
  @IsNotEmpty()
  public triggering_device_id: string;
  @IsString()
  @IsNotEmpty()
  @Matches(/^-?\d+(\.\d+)?\|-?\d+(\.\d+)?$/, {
    message: 'location must be in the format <longitude>|<latitude>',
  })
  public location: string;

  @IsNumber()
  @IsNotEmpty()
  public status_id: number;

  @IsNumber()
  @IsNotEmpty()
  public type_id: number;
}

export class UpdateAlertDto extends CreateAlertDto {
  @IsNumber()
  @IsNotEmpty()
  public id: number;
}

export class DeleteAlertDto extends UpdateAlertDto {}
