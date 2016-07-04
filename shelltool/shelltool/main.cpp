#include <stdio.h>
#include <string>
#include <Windows.h>
#include "tinyxml2.h"


using namespace tinyxml2;

void fixAndroidManifest(char* applicationname, char* filename)
{

	tinyxml2::XMLDocument* doc = new tinyxml2::XMLDocument();
	doc->LoadFile(filename);
	
	XMLElement *root = doc->RootElement();
	XMLElement *application = root->FirstChildElement("application");
	if (application != NULL)
	{

		const char* oldapplicationname = application->Attribute("android:name");
		application->SetAttribute("android:name", applicationname);

		if (oldapplicationname != NULL)
		{
			for (const XMLElement* parent = application->FirstChildElement(); parent; parent = parent->NextSiblingElement())
			{
				if (strcmp(parent->Attribute("android:name"), "VICKY_APPLICATION_CLASS_NAME") == 0)
				{
					application->DeleteChild((XMLElement*)parent);
					break;
				}
			}

			XMLElement* node = doc->NewElement("meta-data");
			node->SetAttribute("android:name", "VICKY_APPLICATION_CLASS_NAME");
			node->SetAttribute("android:value", oldapplicationname);
			application->InsertEndChild(node);
		}

		doc->SaveFile(filename);
	}
}


int main(int argc,char* argv[])
{
	if (argc < 3)
	{
		printf("²ÎÊý´íÎó!");
		return 1;
	}


	if (strcmp(argv[1],"-m")==0)
	{
		fixAndroidManifest(argv[2],argv[3]);
	}

	return 0;
}