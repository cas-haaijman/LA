import { ErrorCodes } from 'vscode-languageclient';
import allowLists, { pragma, pragmas } from './tactics';
import { DocumentProofsResponse, ProofBlock, VscoqExport } from './types';
import { DecorationOptions, Extension, extensions, Location, Position, Range, TextDocument, TextDocumentChangeEvent, TextEditor, Uri, window, workspace } from 'vscode';

// The delay of waiting after each change before updating the decorations
const UPDATE_DELAY_MS = 300;
// The delay of waiting before retrying the server after a busy signal
const SERVER_CANCEL_DELAY_MS = 500;

const decoration = window.createTextEditorDecorationType({
	textDecoration: 'underline wavy #ff0000'
});

type PragmaData = {
	pragma: pragma,
	range?: Range,
}

let timeout: NodeJS.Timeout;

function splitWithRange(text: string, range: Range, separator: string): [string, Range][] {
	const splitText = text.split(separator);
	const textWithRanges: [string, Range][] = [];
	let rangeStart = range.start;
	for (let textFragment of splitText) {
		const lines = textFragment.split("\n");

		let end: Position;
		if (lines.length === 1) {
			end = new Position(rangeStart.line, rangeStart.character + textFragment.length + separator.length);
		} else {
			const lineEnd = rangeStart.line + lines.length - 1;
			const charEnd = lines[lines.length - 1].length;
			end = new Position(lineEnd, charEnd);
		}

		textWithRanges.push([textFragment, new Range(rangeStart, end)]);
		rangeStart = end;
	}
	return textWithRanges;
}

function isPragma(pragma: string): pragma is pragma {
	return pragmas.includes(pragma);
}

function getPragmaData(proofBlock: ProofBlock, editor: TextDocument): PragmaData {
	for (let [lineNumber, line] of editor.getText(proofBlock.range).split("\n").entries()) {
		const pragma = line.replaceAll(/[\(\*\!]|[\*\)]/g, "").trim();
		if (isPragma(pragma)) {
			lineNumber += proofBlock.range.start.line;
			const range = new Range(new Position(lineNumber, 0), new Position(lineNumber, line.length - 1));
			return { pragma, range };
		}
	}
	return { pragma: "default" };
}

function isBeforePragma(pragmaData: PragmaData, proofLine: number): boolean {
	return !!pragmaData.range && pragmaData.range.end.line >= proofLine;
}

function createDecoration(range: Range, tacticName: string, pragma: string): DecorationOptions {
	return {
		range: range,
		hoverMessage: `tactic ${tacticName.replace(".", "")} is not allowed for ${pragma} proofs.`,
	};
}

function createBlockDecorations(proofBlock: ProofBlock, editor: TextDocument): DecorationOptions[] {
	const pragmaData = getPragmaData(proofBlock, editor);

	let allowList = allowLists[pragmaData.pragma];
	const decorations: DecorationOptions[] = [];

	for (let { tactic, range } of proofBlock.steps) {
		if (isBeforePragma(pragmaData, range.start.line)) {
			continue;
		}

		for (const [splitTactic, splitRange] of splitWithRange(tactic, range, ";")) {

			if (allowList.some((allowedTactic) => splitTactic.includes(allowedTactic))) {
				continue;
			}

			decorations.push(createDecoration(splitRange, splitTactic, pragmaData.pragma));
		}
	}

	return decorations;
}

function applyDecorations(decorations: DecorationOptions[]) {
	log.appendLine(`Applied decorations:\n ${JSON.stringify(decorations)}`);
	window.activeTextEditor?.setDecorations(decoration, decorations);
}

export async function createDocumentDecorations(documentProofs: DocumentProofsResponse, document: TextDocument): Promise<DecorationOptions[] | undefined> {
	const decorations = documentProofs.proofs.flatMap((proofBlock) => {

		// make proofBlock.range an actual range, not just an object
		proofBlock.range = new Range(proofBlock.range.start, proofBlock.range.end);

		return createBlockDecorations(proofBlock, document);
	});

	return decorations;
}

// fire decoration update using a small delay
function triggerUpdateDecorations(document: TextDocument, delay = UPDATE_DELAY_MS) {
	if (timeout) {
		clearTimeout(timeout);
	}
	timeout = setTimeout(() => updateDecorations(document), delay);
}

async function updateDecorations(document: TextDocument) {
	if (!window.activeTextEditor) { return; }

	try {

		const documentProofs = await vscoq?.exports.getDocumentProofs(document.uri);

		if (!documentProofs) { return; }

		log.appendLine(`Received parsed file:\n ${JSON.stringify(documentProofs)}`);

		const decorations = await createDocumentDecorations(documentProofs, document);

		if (!decorations) { return; }

		applyDecorations(decorations);
	} catch (e) {
		const ServerCancelledCode = -32802;
		if (e && typeof e === "object" && "code" in e && e.code === ServerCancelledCode) {
			triggerUpdateDecorations(document, SERVER_CANCEL_DELAY_MS);
		}
	}

}

let vscoq: Extension<VscoqExport> | undefined;
const log = window.createOutputChannel('rocq-lna');
export function activate() {
	vscoq = extensions.getExtension('maximedenes.vscoq');
	log.appendLine("Extension activated");

	window.onDidChangeActiveTextEditor(editor => {
		log.appendLine("Active editor changed");
		if (!editor) { return; }

		triggerUpdateDecorations(editor.document);
	});

	workspace.onDidChangeTextDocument(async (event) => {

		if (window.activeTextEditor && event.document === window.activeTextEditor.document) {
			await triggerUpdateDecorations(event.document);
		}
	});
}

// This method is called when your extension is deactivated
export function deactivate() { }