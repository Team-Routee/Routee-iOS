export default {
  source: ["DesignTokens/tokens/**/*.json"],
  platforms: {
    json: {
      transformGroup: "js",
      buildPath: "DesignTokens/build/",
      files: [
        {
          destination: "tokens.flat.json",
          format: "json/flat"
        }
      ]
    }
  }
};
