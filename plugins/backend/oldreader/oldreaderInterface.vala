//	This file is part of FeedReader.
//
//	FeedReader is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	FeedReader is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with FeedReader.  If not, see <http://www.gnu.org/licenses/>.

public class FeedReader.OldReaderInterface : Peas.ExtensionBase, FeedServerInterface {

	private OldReaderAPI m_api;
	private OldReaderUtils m_utils;

	public void init()
	{
		m_api = new OldReaderAPI();
		m_utils = new OldReaderUtils();
	}

	public bool supportTags()
	{
		return false;
	}

	public bool doInitSync()
	{
		return true;
	}

	public string? symbolicIcon()
	{
		return "feed-service-oldreader-symbolic";
	}

	public string? accountName()
	{
		return m_utils.getUser();
	}

	public string? getServerURL()
	{
		return "https://theoldreader.com/";
	}

	public string uncategorizedID()
	{
		return "";
	}

	public bool hideCagetoryWhenEmtpy(string cadID)
	{
		return false;
	}

	public bool supportCategories()
	{
		return true;
	}

	public bool supportFeedManipulation()
	{
		return true;
	}

	public bool supportMultiLevelCategories()
	{
		return false;
	}

	public bool supportMultiCategoriesPerFeed()
	{
		return false;
	}

	public bool tagIDaffectedByNameChange()
	{
		return true;
	}

	public void resetAccount()
    {
        m_utils.resetAccount();
    }

	public bool useMaxArticles()
	{
		return true;
	}

	public LoginResponse login()
	{
		return m_api.login();
	}

	public bool logout()
	{
		return true;
	}

	public void setArticleIsRead(string articleIDs, ArticleStatus read)
	{
		if(read == ArticleStatus.READ)
			m_api.edidTag(articleIDs, "user/-/state/com.google/read");
		else
			m_api.edidTag(articleIDs, "user/-/state/com.google/read", false);
	}

	public void setArticleIsMarked(string articleID, ArticleStatus marked)
	{
		if(marked == ArticleStatus.MARKED)
			m_api.edidTag(articleID, "user/-/state/com.google/starred");
		else
			m_api.edidTag(articleID, "user/-/state/com.google/starred", false);
	}

	public void setFeedRead(string feedID)
	{
		m_api.markAsRead(feedID);
	}

	public void setCategorieRead(string catID)
	{
		m_api.markAsRead(catID);
	}

	public void markAllItemsRead()
	{
		var categories = dbDaemon.get_default().read_categories();
		foreach(category cat in categories)
		{
			m_api.markAsRead(cat.getCatID());
		}

		var feeds = dbDaemon.get_default().read_feeds_without_cat();
		foreach(feed Feed in feeds)
		{
			m_api.markAsRead(Feed.getFeedID());
		}
		m_api.markAsRead();
	}

	public void tagArticle(string articleID, string tagID)
	{
		m_api.edidTag(articleID, tagID, true);
	}

	public void removeArticleTag(string articleID, string tagID)
	{
		m_api.edidTag(articleID, tagID, false);
	}

	public string createTag(string caption)
	{
		return m_api.composeTagID(caption);
	}

	public void deleteTag(string tagID)
	{
		m_api.deleteTag(tagID);
	}

	public void renameTag(string tagID, string title)
	{
		m_api.renameTag(tagID, title);
	}

	public bool serverAvailable()
	{
		return m_api.ping();
	}

	public string addFeed(string feedURL, string? catID, string? newCatName)
	{
		if(catID == null && newCatName != null)
		{
			string newCatID = m_api.composeTagID(newCatName);
			m_api.editSubscription(OldReaderAPI.OldreaderSubscriptionAction.SUBSCRIBE, {"feed/"+feedURL}, null, newCatID);
		}
		else
		{
			m_api.editSubscription(OldReaderAPI.OldreaderSubscriptionAction.SUBSCRIBE, {"feed/"+feedURL}, null, catID);
		}
		return "feed/" + feedURL;
	}

	public void addFeeds(Gee.LinkedList<feed> feeds)
	{
		string cat = "";
		string[] urls = {};

		foreach(feed f in feeds)
		{
			if(f.getCatIDs()[0] != cat)
			{
				m_api.editSubscription(OldReaderAPI.OldreaderSubscriptionAction.SUBSCRIBE, urls, null, cat);
				urls = {};
				cat = f.getCatIDs()[0];
			}

			urls += "feed/" + f.getXmlUrl();
		}

		m_api.editSubscription(OldReaderAPI.OldreaderSubscriptionAction.SUBSCRIBE, urls, null, cat);
	}


	public void removeFeed(string feedID)
	{
		m_api.editSubscription(OldReaderAPI.OldreaderSubscriptionAction.UNSUBSCRIBE, {feedID});
	}

	public void renameFeed(string feedID, string title)
	{
		m_api.editSubscription(OldReaderAPI.OldreaderSubscriptionAction.EDIT, {feedID}, title);
	}

	public void moveFeed(string feedID, string newCatID, string? currentCatID)
	{
		m_api.editSubscription(OldReaderAPI.OldreaderSubscriptionAction.EDIT, {feedID}, null, newCatID, currentCatID);
	}

	public string createCategory(string title, string? parentID)
	{
		return m_api.composeTagID(title);
	}

	public void renameCategory(string catID, string title)
	{
		m_api.renameTag(catID, title);
	}

	public void moveCategory(string catID, string newParentID)
	{
		return;
	}

	public void deleteCategory(string catID)
	{
		m_api.deleteTag(catID);
	}

	public void removeCatFromFeed(string feedID, string catID)
	{
		return;
	}

	public void importOPML(string opml)
	{
		var parser = new OPMLparser(opml);
		parser.parse();
	}

	public bool getFeedsAndCats(Gee.LinkedList<feed> feeds, Gee.LinkedList<category> categories, Gee.LinkedList<tag> tags)
	{
		if(m_api.getFeeds(feeds)
		&& m_api.getCategoriesAndTags(feeds, categories, tags))
			return true;
		return false;
	}

	public int getUnreadCount()
	{
		return m_api.getTotalUnread();
	}

	public void getArticles(int count, ArticleStatus whatToGet, string? feedID, bool isTagID)
	{
		if(whatToGet == ArticleStatus.READ)
		{
			return;
		}
		else if(whatToGet == ArticleStatus.ALL)
		{
			var unreadIDs = new Gee.LinkedList<string>();
			string? continuation = null;
			int left = 4*count;

			while(left > 0)
			{
				if(left > 1000)
				{
					continuation = m_api.updateArticles(unreadIDs, 1000, continuation);
					left -= 1000;
				}
				else
				{
					m_api.updateArticles(unreadIDs, left, continuation);
					left = 0;
				}
			}
			dbDaemon.get_default().updateArticlesByID(unreadIDs, "unread");
			updateArticleList();
		}

		var articles = new Gee.LinkedList<article>();
		string? continuation = null;
		int left = count;
		string? OldReader_feedID = (isTagID) ? null : feedID;
		string? OldReader_tagID = (isTagID) ? feedID : null;

		while(left > 0)
		{
			if(left > 1000)
			{
				continuation = m_api.getArticles(articles, 1000, whatToGet, continuation, OldReader_tagID, OldReader_feedID);
				left -= 1000;
			}
			else
			{
				continuation = m_api.getArticles(articles, left, whatToGet, continuation, OldReader_tagID, OldReader_feedID);
				left = 0;
			}
		}
		writeArticles(articles);
	}

}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module)
{
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof(FeedReader.FeedServerInterface), typeof(FeedReader.OldReaderInterface));
}
