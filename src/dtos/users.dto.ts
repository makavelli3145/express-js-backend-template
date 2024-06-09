import {
  ValidatorConstraint,
  ValidatorConstraintInterface,
  ValidationArguments,
  IsString,
  MinLength,
  MaxLength,
  Validate,
  IsNotEmpty,
} from 'class-validator';
import * as querystring from 'querystring';

@ValidatorConstraint({ name: 'isValidSouthAfricanId', async: false })
class IsValidSouthAfricanId implements ValidatorConstraintInterface {
  validate(idNumber: string, args: ValidationArguments) {
    const regex = /^(?<birthdate>\d{6})(?<gender>[5-9]\d{3})0\d{2}\d{2}$/;
    const matches = idNumber.match(regex);

    if (!matches) {
      return false; // Invalid format
    }

    const { birthdate, gender } = matches.groups;

    // Check birthdate range
    const currentYear = new Date().getFullYear();
    const century = birthdate.charAt(0) <= currentYear.toString().charAt(2) ? '20' : '19';
    const birthYear = parseInt(century + birthdate.substr(0, 2));
    const age = currentYear - birthYear;

    if (age > 110) {
      return false; // Person is older than 110 years
    }

    // Check gender
    const isMale = parseInt(gender) >= 5000;

    // Check country ID
    const countryId = parseInt(idNumber.charAt(10));
    if (countryId !== 0) {
      return false; // Not South Africa
    }

    // Check last digit (check bit)
    const lastDigit = parseInt(idNumber.charAt(12));
    const digits = idNumber.substring(0, 12).split('').map(Number);
    const checksum =
      (digits[0] * 2 +
        digits[1] * 3 +
        digits[2] * 4 +
        digits[3] * 5 +
        digits[4] * 6 +
        digits[5] * 7 +
        digits[6] * 8 +
        digits[7] * 9 +
        digits[8] * 10 +
        digits[9] * 1 +
        digits[10] * 2) %
      11;

    return (checksum < 10 ? checksum : 0) === lastDigit;
  }

  defaultMessage(args: ValidationArguments) {
    return 'Invalid South African ID number';
  }
}

export class CreateUserDto {
  @IsString()
  @Validate(IsValidSouthAfricanId, {
    message: 'Invalid South African ID number',
  })
  @IsNotEmpty()
  public idNumber: string;

  @IsString()
  @MinLength(6)
  @IsNotEmpty()
  @MaxLength(6)
  public pinCode: string;

  @IsString()
  @IsNotEmpty()
  public name: string;
}

