import re
ontology = None

class ontologyNode:
    def __init__(self, id, name, namespace, definition, parentInfo, parentId, relationship, synonym):
        self.id = id
        self.name = name
        self.namespace = namespace
        self.definition = definition
        self.parentInfo = parentInfo
        self.parentId = parentId
    # is a list
        self.relationship = relationship
    # is a list
        self.synonym = synonym

def loadOntology(fileName):
    ontologyFile = open(fileName,'r')
    flagNewTerm = False
    ontology = dict()

    # initialize buffer variables
    id = None
    name = None
    namespace = None
    definition = None
    parent = None
    relationship = list()
    synonym = list()

    for line in ontologyFile:
        if '[Term]' in line:
            break

    for line in ontologyFile:
    # sample data block in ontologyFile
    # [Term]
    # id: ARO:0000000
    # name: macrolide antibiotic
    # namespace: antibiotic_resistance
    # def: "Macrolides are a group of drugs (typically antibiotics) that have a large macrocyclic lactone ring of 12-16 carbons to which one or more deoxy sugars, usually cladinose and desosamine, may be attached. Macrolides bind to the 50S-subunit of bacterial ribosomes, inhibiting the synthesis of vital proteins." [PMID:27480866, PMID:15544496, PMID:11324679]
    # is_a: ARO:1000003 ! antibiotic molecule        
    # synonym: "fluoroquinolone" EXACT []
    # synonym: "quinolone" EXACT []
    # xref: pubchem.compound:5284517
    # relationship: confers_resistance_to_drug_class ARO:3000050 ! tetracycline antibiotic
        if line == '\n':
            continue
        if '[Term]' in line or '[Typedef]' in line:
            ontology[id] = ontologyNode(id,name,namespace,definition,parentInfo, parentId,relationship,synonym)
            id = None
            name = None
            namespace = None
            definition = None
            parentInfo = None
            parentId = None
            relationship = list()
            synonym = list()
            continue
        

        # fields = line.replace('\n','').split(': ')
        line = line.replace('\n','')
        field = line[0:line.find(':')]
        data = line[line.find(':')+len(': '):]
        

        if field == 'id':
            id = data
        elif field == 'name':
            name = data
        elif field == 'namespace':
            namespace = data
        elif field == 'def':
            definition = data
        elif field == 'is_a':
            parentInfo = data
            parentId = parentInfo.split(' ! ')[0]
            if len(parentInfo.split(' ! '))>2:
                print(f'multiple parents: {line}')
        elif field == 'synonym':
            synonym.append(data)
        elif field == 'xref':
            pass
        elif field == 'relationship':
            relationship = data
        else:
            print(f'extra info: "{line}"')
    return ontology
        
def getOntologyTrace(id, ontology):
    ids = list()
    names = list()
    node = ontology[id]

    ids.append(node.id)
    names.append(node.name)
    while node.parentId != None:
        node = ontology[node.parentId]
        ids.append(node.id)
        names.append(node.name)
    return ids, names

def traceToString(trace):
    s = trace[0]
    for i in trace[1:]:
        s += f'|{i}'
    return s

def loadCard(fileName):
    card = open('aro_index.tsv','r')
    aro = dict()
    for line in card:
    # sample line
    # 0             1           2                   3           4           5           6                   7               8               9           10                      11  
    # ARO Accession	CVTERM ID	Model Sequence ID	Model ID	Model Name	ARO Name	Protein Accession	DNA Accession	AMR Gene Family	Drug Class	Resistance Mechanism	CARD Short Name    
    # ARO:3007014	45483	8126	5730	qacJ	qacJ	CAD55144.1	AJ512814.1	small multidrug resistance (SMR) antibiotic efflux pump	disinfecting agents and antiseptics	antibiotic efflux	qacJ
        fields = line.split('\t')
        aroId = fields[0]
        name = fields[5].lower()
        name = re.sub('\W+','', name)
        family = fields[8]
        drugClass = fields[9]
        mechanism = fields[10]
        aro[name] = [ family, drugClass, mechanism, aroId ]
    card.close()

# fix miss named genes
    aro["aac6iag"] = aro["aac6i48"]
    aro["aaca43"] = aro["aac6i43"]
    aro["aph3xva"] = aro["aph3ia"]
    aro["ompk37"] = aro["klebsiellapneumoniaeompk37"] #Kpne_OmpK37
    aro["kpnh"] = aro["klebsiellapneumoniaekpnh"] #Kpne_KpnH
    aro["kpng"] = aro["klebsiellapneumoniaekpng"] #Kpne_KpnG

    return aro

ontology = loadOntology('aro.obo')
aro = loadCard('aro_index.tsv')

camda = open('amr-counts_20230604.tsv','r')
out = open('amr-counts_card_info.tsv','w')
out.write(f'name\tARO\tARO_Trace\tAro_name_trace\tfamily\tdrugClass\tmechanism\t{camda.readline()[1:]}')

for line in camda:
    gene = line.split('\t')[0].lower()
    gene =  re.sub('\W+','', gene)
    family, drugclass, mechanism, aroId = aro[gene]
    aroTrace, nameTrace = getOntologyTrace(aroId,ontology)
    out.write(f'{gene}\t{aroId}\t{traceToString(aroTrace)}\t{traceToString(nameTrace)}\t{family}\t{drugclass}\t{mechanism}\t{line[len(gene)+1:]}')

out.close()