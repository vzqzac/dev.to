import { h } from 'preact';
import { articleSnippetResultPropTypes } from '../../src/components/common-prop-types';

export const SearchSnippet = ({ snippetResult }) => {
  if (snippetResult && snippetResult.body_text) {
    let bodyTextSnippet = '';

    if (snippetResult.body_text.matchLevel !== 'none') {
      const firstSnippetChar = snippetResult.body_text.value[0];

      let startingEllipsis = '';
      if (firstSnippetChar.toLowerCase() !== firstSnippetChar.toUpperCase()) {
        startingEllipsis = '…';
      }

      bodyTextSnippet = `${startingEllipsis + snippetResult.body_text.value}…`;
    }

    if (bodyTextSnippet.length > 0) {
      return (
        <div className="search-snippet">
          <span>{bodyTextSnippet}</span>
        </div>
      );
    }
  }

  return null;
};

SearchSnippet.propTypes = {
  // eslint-disable-next-line no-underscore-dangle
  snippetResult: articleSnippetResultPropTypes.isRequired,
};

SearchSnippet.displayName = 'SearchSnippet';
