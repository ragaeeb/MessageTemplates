#include "MessageImporter.h"
#include "Logger.h"

#include <bb/pim/contacts/ContactService>
#include <bb/pim/message/MessageFilter>
#include <bb/pim/message/MessageService>

namespace canadainc {

using namespace bb::pim::contacts;
using namespace bb::pim::message;

MessageImporter::MessageImporter(qint64 accountKey) : m_accountKey(accountKey)
{
}

void MessageImporter::run()
{
	LOGGER("MessageImporter::run()" << m_accountKey);

    MessageService ms;
	QList<Conversation> conversations = ms.conversations( m_accountKey, MessageFilter() );

	QVariantList result;

	int total = conversations.size();
	LOGGER("==== TOTAL" << total);

	for (int i = 0; i < total; i++)
	{
		Conversation c = conversations[i];
		Message m = ms.message( m_accountKey, c.latestMessageId() );

		if ( !m.isDraft() && m.isValid() && m.isInbound() )
		{
			QString text = m.body(MessageBody::PlainText).plainText();

			if ( text.isEmpty() ) {
				text = m.body(MessageBody::Html).plainText();
			};

			QVariantMap qvm;
			LOGGER("========== MESSAGE ID" << m.id());
			qvm.insert( "id", m.id() );
			qvm.insert( "text", text );
			qvm.insert( "sender", m.sender().displayableName() );
			qvm.insert( "time", m.serverTimestamp() );
			qvm.insert( "subject", m.subject() );
			qvm.insert( "senderAddress", m.sender().address() );

			result << qvm;
		}

		emit progress(i, total);
	}

	LOGGER( "Elements generated:" << result.size() );
	emit progress(total, total);
	emit importCompleted(result);
}


MessageImporter::~MessageImporter()
{
}

} /* namespace canadainc */
