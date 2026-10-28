import { readFileSync, appendFileSync } from 'node:fs';

const report = readFileSync('unittests.xml', 'utf8');
const suite = report.match(/<testsuite\b([^>]*)>/);
if (!suite) throw new Error('The nose XML report has no test suite.');
const attrs = Object.fromEntries(
  [...suite[1].matchAll(/([\w-]+)="([^"]*)"/g)].map((match) => [match[1], match[2]])
);
const tests = Number(attrs.tests);
const failures = Number(attrs.failures);
const errors = Number(attrs.errors);
if (![tests, failures, errors].every(Number.isFinite) || tests < 1) {
  throw new Error('The nose XML report must contain executed tests and valid counts.');
}
const message = `Nose: ${tests} tests, ${failures} failures, ${errors} errors.`;
console.log(message);
if (process.env.GITHUB_STEP_SUMMARY) {
  appendFileSync(process.env.GITHUB_STEP_SUMMARY, `## Unit tests\n\n${message}\n`);
}
if (failures || errors) process.exitCode = 1;
