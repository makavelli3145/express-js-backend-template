import {
  IsNotEmpty,
  IsString,
  IsNumber,
  MaxLength,
  MinLength,
  Validate,
  ValidationArguments,
  ValidatorConstraint,
  ValidatorConstraintInterface,
  IsUUID,
} from 'class-validator';
import * as console from 'console';

@ValidatorConstraint({ name: 'isValidSouthAfricanId', async: false })
class IsValidSouthAfricanId implements ValidatorConstraintInterface {
  validate(idNumber: string, args: ValidationArguments) {
    if (typeof idNumber !== 'string' || !idNumber.trim()) {
      return false;
    }

    const regex = /^(?<idnumber>(?<birthdate>\d{6})(?<gender>\d{4})(\d{3}))/;
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
    if (age > 130) {
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
    const digits = idNumber.substring(0, 13).split('').map(Number);
    return luhnsChecksum(digits);
  }

  defaultMessage(args: ValidationArguments) {
    return 'Invalid South African ID number';
  }
}

function luhnsChecksum(digitArray: number[]): boolean {
  let sum = 0;
  const length = digitArray.length;

  // Loop through the digits, starting from the end
  for (let i = length - 1; i >= 0; i--) {
    let digit = digitArray[i];

    // Double every second digit
    if ((length - i) % 2 === 0) {
      digit *= 2;
      // If doubling results in a number greater than 9, add the digits of the result
      if (digit > 9) {
        digit -= 9;
      }
    }

    sum += digit;
  }

  // Check if the sum is a multiple of 10
  return sum % 10 === 0;
}

export class CreateUserDto {
  @IsString()
  @Validate(IsValidSouthAfricanId, {
    message: 'Invalid South African ID number',
  })
  @IsNotEmpty()
  public id_number: string;

  @IsString()
  @MinLength(4)
  @IsNotEmpty()
  @MaxLength(4)
  public pin: string;

  @IsString()
  @IsNotEmpty()
  public name: string;
}

export class DeleteUserDto {
  @IsNotEmpty()
  @IsNumber()
  public id: number;
}

export class LoginUserDto {
  @IsNotEmpty()
  @IsNumber()
  public id: number;

  @IsNotEmpty()
  @IsNumber()
  public user_id: number;

  @IsNotEmpty()
  @IsString()
  @IsUUID(4)
  public device_uuid: string;
}
