const fs = require("fs");
const path = require("path");
const Ajv = require("ajv");
const standaloneCode = require("ajv/dist/standalone").default;

const schemaAvailability = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "#/definitions/SchemaAvailability",
  "definitions": {
    "DayAvailabilitySchema": {
      "properties": {
        "isAvailable": {"type": "boolean"},
        "startHourUtc": {"type": "integer"},
        "startMinuteUtc": {"type": "integer"},
        "endHourUtc": {"type": "integer"},
        "endMinuteUtc": {"type": "integer"},
      },
      "required": ["isAvailable", "startHourUtc", "startMinuteUtc", "endHourUtc", "endMinuteUtc"],
      "type": "object",
    },
  },
  "properties": {
    "mondayAvailability": {"$ref": "#/definitions/DayAvailabilitySchema"},
    "tuesdayAvailability": {"$ref": "#/definitions/DayAvailabilitySchema"},
    "wednesdayAvailability": {"$ref": "#/definitions/DayAvailabilitySchema"},
    "thursdayAvailability": {"$ref": "#/definitions/DayAvailabilitySchema"},
    "fridayAvailability": {"$ref": "#/definitions/DayAvailabilitySchema"},
    "saturdayAvailability": {"$ref": "#/definitions/DayAvailabilitySchema"},
    "sundayAvailability": {"$ref": "#/definitions/DayAvailabilitySchema"},
  },
  "required": ["mondayAvailability", "tuesdayAvailability", "wednesdayAvailability", "thursdayAvailability", "fridayAvailability", "saturdayAvailability", "sundayAvailability"],
  "type": "object",
};

// For ESM, the export name needs to be a valid export name, it can not be `export const #/definitions/Foo = ...;` so we
// need to provide a mapping between a valid name and the $id field. Below will generate
// `export const Foo = ...;export const Bar = ...;`
// This mapping would not have been needed if the `$ids` was just `Bar` and `Foo` instead of `#/definitions/Foo`
// and `#/definitions/Bar` respectfully
const ajv = new Ajv({schemas: [schemaAvailability], code: {source: true, esm: true}});
const moduleCode = standaloneCode(ajv, {
  "expertAvailabilitySchemaValidator": "#/definitions/SchemaAvailability",
});

// Now you can write the module code to file
fs.writeFileSync(path.join(__dirname, "./expert_availability_validator.js"), moduleCode);
