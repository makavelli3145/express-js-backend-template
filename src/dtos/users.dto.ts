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
} from 'class-validator';

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
    const digits = idNumber.substring(0, 12).split('').map(Number);
    return luhnsChecksum(digits);
  }

  defaultMessage(args: ValidationArguments) {
    return 'Invalid South African ID number';
  }
}

function luhnsChecksum(digitArray: number[]): boolean {
  let result: number = 0;
  digitArray.forEach((digit, index) => {
    if (index === digitArray.length - 1) {
      if (digit * 2 > 10 && index % 2 === 0) {
        const stringDigit = digit.toString();
        const firstDigit = parseInt(stringDigit.charAt(0));
        const secondDigit = parseInt(stringDigit.charAt(1));
        result += firstDigit + secondDigit;
      } else {
        result += digit;
      }
    }
    let remainder = result % 10;
    if (remainder > 0) {
      result = 10 - remainder;
    } else {
      result = remainder;
    }
  });
  return result === digitArray[digitArray.length - 1];
}

export class CreateUserDto {
  @IsString()
  @Validate(IsValidSouthAfricanId, {
    message: 'Invalid South African ID number',
  })
  @IsNotEmpty()
  public id_number: string;

  @IsString()
  @MinLength(6)
  @IsNotEmpty()
  @MaxLength(6)
  public pin: string;

  @IsString()
  @IsNotEmpty()
  public name: string;

  @IsNumber()
  public id?: number;
}
