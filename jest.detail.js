module.exports = {
    testEnvironment: "<rootDir>/src/detail/generated/detail.environment.ts",
    setupFilesAfterEnv: ["<rootDir>/src/detail/generated/detail.setup.ts"],
    transform: {
      "^.+\\.[tj]sx?$": [
        "ts-jest",
        {
          isolatedModules: true,
        },
      ],
    },
    moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
    testTimeout: 20000, // 20 seconds
  };