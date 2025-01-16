import * as assert from 'assert';
import * as vscode from 'vscode';
import * as myExtension from '../extension';
import path from "path";
import { DocumentProofsResponse } from '../types';
import fs from "fs";

const coqFilesDir = path.resolve(__dirname, "../../src/test/coq-files");
const parsedCoqFilesDir = path.resolve(__dirname, "../../src/test/coq-files-parsed");
const expectedResponseDir = path.resolve(__dirname, "../../src/test/coq-files-expected");

suite('Extension Test Suite', () => {
	vscode.window.showInformationMessage('Start all tests.');

	function loadDocument(fileName: string): Thenable<vscode.TextDocument> {
		const docPath = path.resolve(coqFilesDir, fileName);
		const uri = vscode.Uri.file(docPath);
		return vscode.workspace.openTextDocument(uri);
	}

	function loadParsedProof(fileName: string): DocumentProofsResponse {
		const parsedPath = path.resolve(parsedCoqFilesDir, fileName);
		const json = fs.readFileSync(parsedPath, 'utf-8');
		return JSON.parse(json);
	}

	function loadExpectedResponse(fileName: string): vscode.DecorationOptions[] {
		const expectedResponsePath = path.resolve(expectedResponseDir, fileName);
		const json = fs.readFileSync(expectedResponsePath, 'utf-8');
		return JSON.parse(json);
	}

	function asJson(fileName: string) {
		return `${fileName.split(".")[0]}.json`;
	}

	async function loadData(fileName: string) {
		return {
			document: await loadDocument(fileName),
			parsedProofs: loadParsedProof(asJson(fileName)),
			expectedResponse: loadExpectedResponse(asJson(fileName))
		};
	}

	async function testCoqFile(fileName: string) {
		const { parsedProofs, document, expectedResponse } = await loadData(fileName);

		const response = await myExtension.createDocumentDecorations(parsedProofs, document);

		const stringifiedParsedResponse = JSON.parse(JSON.stringify(response));

		// console.log("--------------------------------------------------------");
		assert.equal(JSON.stringify(process.argv), "");
		// console.log("--------------------------------------------------------");


		assert.deepEqual(stringifiedParsedResponse, expectedResponse, `found change in ${fileName}`);
		// assert.deepEqual(stringifiedParsedResponse, "", `found change in ${fileName}`);
	}

	const coqFileNames = fs.readdirSync(coqFilesDir);

	coqFileNames.every((fileName) => test(`test ${fileName}`, () => testCoqFile(fileName)));
});
